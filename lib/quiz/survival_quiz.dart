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

/// Survival Quiz Mode - Answer correctly in a row, lose when you answer wrong
class SurvivalQuiz extends StatefulWidget {
  const SurvivalQuiz({Key? key}) : super(key: key);

  @override
  State<SurvivalQuiz> createState() => _SurvivalQuizState();
}

class _SurvivalQuizState extends State<SurvivalQuiz> {
  String? selectedAnswerIndex;
  bool answerClicked = false;
  int? _ratingChange;
  bool _statsUpdated = false;
  int? _lastQuestionIndex;
  List<MapEntry<String, bool>>? _shuffledAnswers;
  List<Achievement> _newAchievements = [];
  bool _gameOver = false;

  List<MapEntry<String, bool>> _getShuffledAnswers(
    Map<String, bool> answers,
    int questionIndex,
  ) {
    if (_lastQuestionIndex != questionIndex || _shuffledAnswers == null) {
      _lastQuestionIndex = questionIndex;
      _shuffledAnswers = answers.entries.toList()..shuffle();
    }
    return _shuffledAnswers!;
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
    if (answerClicked || _gameOver) return;

    setState(() {
      selectedAnswerIndex = index;
      answerClicked = true;
    });

    Future.delayed(AppConstants.answerFeedbackDuration, () {
      if (mounted) {
        final quizProvider = Provider.of<QuizProvider>(context, listen: false);
        
        // In survival mode, game ends if answer is wrong
        if (quizProvider.shouldEndSurvival(isCorrect)) {
          setState(() {
            _gameOver = true;
          });
        }
        
        quizProvider.answerQuestion(isCorrect);

        setState(() {
          selectedAnswerIndex = null;
          answerClicked = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Check if game is over (wrong answer or all questions completed)
    if (_gameOver || quizProvider.isQuizComplete) {
      final result = quizProvider.getResult();

      // Update user statistics (only once)
      if (userProvider.isLoggedIn && !_statsUpdated) {
        _ratingChange = userProvider.getRatingChange(
          score: result.score,
          totalQuestions: result.totalQuestions,
        );
        _statsUpdated = true;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          userProvider.completeQuiz(
            score: result.score,
            totalQuestions: result.totalQuestions,
          );
          _updateUserData(userProvider);
          _checkAchievements(userProvider, result.score, result.totalQuestions);
        });
      }

      return Result(
        quizResult: result,
        ratingChange: _ratingChange,
        newAchievements: _newAchievements,
        gameMode: quizProvider.gameMode,
        questionsAnswered: quizProvider.maxStreak,
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 8),
                Text("Streak: ${quizProvider.streak}"),
              ],
            ),
            Text(
              "Best: ${quizProvider.maxStreak}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.primaryText,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Warning message
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'One wrong answer and you\'re out!',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Question(currentQuestion.text),
            const SizedBox(height: 20),
            ..._getShuffledAnswers(
              currentQuestion.answers,
              quizProvider.currentQuestionIndex,
            ).map<Widget>((entry) {
              final String answerText = entry.key;
              final bool isCorrect = entry.value;

              return Answer(
                () => _handleAnswer(isCorrect, answerText),
                answerText,
                isSelected: selectedAnswerIndex == answerText,
                isCorrectAnswer: isCorrect,
                isDisabled: answerClicked,
              );
            }),
          ],
        ),
      ),
    );
  }
}
