import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'question.dart';
import 'answer.dart';
import 'result.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../providers/quiz_provider.dart';
import '../providers/user_provider.dart';
import '../services/database_service.dart';
import '../services/achievement_service.dart';
import '../models/achievement_model.dart';
import '../service_locator.dart';

class Quiz extends StatefulWidget {
  const Quiz({Key? key}) : super(key: key);

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  String? selectedAnswerIndex;
  bool answerClicked = false;
  int? _ratingChange;
  bool _statsUpdated = false;
  int? _lastQuestionIndex;
  List<MapEntry<String, bool>>? _shuffledAnswers;
  List<Achievement> _newAchievements = [];

  List<MapEntry<String, bool>> _getShuffledAnswers(
    Map<String, bool> answers,
    int questionIndex,
  ) {
    // Reshuffle when moving to a new question
    if (_lastQuestionIndex != questionIndex || _shuffledAnswers == null) {
      _lastQuestionIndex = questionIndex;
      _shuffledAnswers = answers.entries.toList()..shuffle();

      // Reset the currently selected answer and click state when navigating
      // but after build completes to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            selectedAnswerIndex = null;
            answerClicked = false;
          });
        }
      });
    }
    return _shuffledAnswers!;
  }

  // Get the selected answer for the current question from answeredQuestions
  String? _getSelectedAnswerForCurrentQuestion(QuizProvider quizProvider) {
    final currentQuestion = quizProvider.currentQuestion;
    if (currentQuestion == null) return null;

    final wasAnswered =
        quizProvider.answeredQuestions[quizProvider.currentQuestionIndex];
    if (wasAnswered == null) return null;

    // Find which answer was selected (the correct one if wasAnswered is true, or an incorrect one)
    for (var entry in currentQuestion.answers.entries) {
      if (wasAnswered && entry.value) {
        // They answered correctly, so they selected the correct answer
        return entry.key;
      } else if (!wasAnswered && !entry.value) {
        // They answered incorrectly - we need to figure out which wrong answer
        // For now, we'll just mark that they answered (showing feedback)
        // but we can't determine which specific wrong answer was selected
        return entry.key; // Return first wrong answer as placeholder
      }
    }
    return null;
  }

  Future<void> _updateUserData(UserProvider userProvider) async {
    final databaseService = getIt<DatabaseService>();

    if (userProvider.userId.isNotEmpty) {
      try {
        await databaseService.update(
          path: AppConstants.userDataCollection,
          id: userProvider.userId,
          data: userProvider.getStatistics(),
        );
      } catch (e) {
        // Log error but don't prevent navigation
        debugPrint('Failed to update user data: $e');
      }
    }
  }

  Future<void> _checkAchievements(
    UserProvider userProvider,
    int score,
    int totalQuestions,
  ) async {
    try {
      final achievementService = getIt<AchievementService>();
      final newAchievements = await achievementService
          .checkAndUnlockAchievements(
            userId: userProvider.userId,
            user: userProvider.currentUser,
            quizScore: score,
            quizTotalQuestions: totalQuestions,
          );

      if (newAchievements.isNotEmpty && mounted) {
        setState(() {
          _newAchievements = newAchievements;
        });
      }
    } catch (e) {
      debugPrint('Failed to check achievements: $e');
    }
  }

  void _handleAnswer(bool isCorrect, String index) {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    // Prevent answering if already answered or currently processing
    if (quizProvider.hasAnsweredCurrentQuestion || answerClicked) return;

    setState(() {
      selectedAnswerIndex = index;
      answerClicked = true;
    });

    // Submit the answer without auto-advancing
    quizProvider.submitAnswer(isCorrect, index);
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Check if quiz is complete
    if (quizProvider.isQuizComplete) {
      final result = quizProvider.getResult();

      // Update user statistics (only once, deferred to avoid setState during build)
      if (userProvider.isLoggedIn && !_statsUpdated) {
        // Calculate rating change before updating
        _ratingChange = userProvider.getRatingChange(
          score: result.score,
          totalQuestions: result.totalQuestions,
        );
        _statsUpdated = true;

        // Defer the state update to after the build phase
        WidgetsBinding.instance.addPostFrameCallback((_) {
          userProvider.completeQuiz(
            score: result.score,
            totalQuestions: result.totalQuestions,
          );
          _updateUserData(userProvider);
          // Check for new achievements
          _checkAchievements(userProvider, result.score, result.totalQuestions);
        });
      }

      return Result(
        quizResult: result,
        ratingChange: _ratingChange,
        newAchievements: _newAchievements,
      );
    }

    final currentQuestion = quizProvider.currentQuestion;
    if (currentQuestion == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: const Center(
          child: Text(
            'No questions available',
            style: TextStyle(color: AppColors.primaryText),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(
          "Question ${quizProvider.currentQuestionIndex + 1}/${quizProvider.totalQuestions}",
        ),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.primaryText,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Question(currentQuestion.text),
            const SizedBox(height: 20),
            ..._getShuffledAnswers(
              currentQuestion.answers,
              quizProvider.currentQuestionIndex,
            ).map<Widget>((entry) {
              final String answerText = entry.key;
              final bool isCorrect = entry.value;

              // Check if this question was already answered
              final wasAnswered = quizProvider.hasAnsweredCurrentQuestion;
              final isCurrentlySelected = selectedAnswerIndex == answerText;

              // Get the previously selected answer for this question
              final previouslySelectedAnswer = quizProvider
                  .selectedAnswers[quizProvider.currentQuestionIndex];
              final wasPreviouslySelected =
                  previouslySelectedAnswer == answerText;

              // Show selection if currently clicked or if this was the previously selected answer
              final shouldShowSelected =
                  isCurrentlySelected || wasPreviouslySelected;

              return Answer(
                () => _handleAnswer(isCorrect, answerText),
                answerText,
                isSelected: shouldShowSelected,
                isCorrectAnswer: isCorrect,
                isDisabled: wasAnswered,
              );
            }),
            const SizedBox(height: 40),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  ElevatedButton.icon(
                    onPressed: quizProvider.canGoBack
                        ? () {
                            quizProvider.previousQuestion();
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardBackground,
                      foregroundColor: AppColors.primaryText,
                      disabledBackgroundColor: AppColors.cardBackground
                          .withOpacity(0.5),
                      disabledForegroundColor: AppColors.primaryText
                          .withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  // Next button
                  ElevatedButton.icon(
                    onPressed:
                        (quizProvider.canGoForward ||
                            (quizProvider.currentQuestionIndex ==
                                    quizProvider.totalQuestions - 1 &&
                                quizProvider.hasAnsweredCurrentQuestion))
                        ? () {
                            quizProvider.nextQuestion();
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      quizProvider.currentQuestionIndex ==
                              quizProvider.totalQuestions - 1
                          ? 'Finish'
                          : 'Next',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButton,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primaryButton
                          .withOpacity(0.5),
                      disabledForegroundColor: Colors.white.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
