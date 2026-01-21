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

/// Arcade Quiz Mode - Classic mode with power-ups
class ArcadeQuiz extends StatefulWidget {
  const ArcadeQuiz({Key? key}) : super(key: key);

  @override
  State<ArcadeQuiz> createState() => _ArcadeQuizState();
}

class _ArcadeQuizState extends State<ArcadeQuiz> {
  String? selectedAnswerIndex;
  bool answerClicked = false;
  int? _ratingChange;
  bool _statsUpdated = false;
  int? _lastQuestionIndex;
  List<MapEntry<String, bool>>? _shuffledAnswers;
  List<Achievement> _newAchievements = [];
  
  // Power-ups
  int _fiftyFiftyCount = 2; // Remove 2 wrong answers
  int _skipCount = 1; // Skip question (counts as correct)
  bool _fiftyFiftyUsed = false;
  List<String> _hiddenAnswers = [];

  List<MapEntry<String, bool>> _getShuffledAnswers(
    Map<String, bool> answers,
    int questionIndex,
  ) {
    if (_lastQuestionIndex != questionIndex || _shuffledAnswers == null) {
      _lastQuestionIndex = questionIndex;
      _shuffledAnswers = answers.entries.toList()..shuffle();
      _fiftyFiftyUsed = false;
      _hiddenAnswers = [];
    }
    return _shuffledAnswers!;
  }

  void _useFiftyFifty() {
    if (_fiftyFiftyCount <= 0 || _fiftyFiftyUsed || answerClicked) return;

    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final currentQuestion = quizProvider.currentQuestion;
    if (currentQuestion == null) return;

    setState(() {
      _fiftyFiftyCount--;
      _fiftyFiftyUsed = true;

      // Find wrong answers and hide 2 of them
      final wrongAnswers = _shuffledAnswers!
          .where((entry) => !entry.value)
          .map((entry) => entry.key)
          .toList();
      
      if (wrongAnswers.length >= 2) {
        _hiddenAnswers = wrongAnswers.sublist(0, 2);
      } else {
        _hiddenAnswers = wrongAnswers;
      }
    });
  }

  void _useSkip() {
    if (_skipCount <= 0 || answerClicked) return;

    setState(() {
      _skipCount--;
      answerClicked = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final quizProvider = Provider.of<QuizProvider>(context, listen: false);
        quizProvider.answerQuestion(true); // Count as correct

        setState(() {
          selectedAnswerIndex = null;
          answerClicked = false;
          _fiftyFiftyUsed = false;
          _hiddenAnswers = [];
        });
      }
    });
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
    if (answerClicked) return;

    setState(() {
      selectedAnswerIndex = index;
      answerClicked = true;
    });

    Future.delayed(AppConstants.answerFeedbackDuration, () {
      if (mounted) {
        final quizProvider = Provider.of<QuizProvider>(context, listen: false);
        quizProvider.answerQuestion(isCorrect);

        setState(() {
          selectedAnswerIndex = null;
          answerClicked = false;
          _fiftyFiftyUsed = false;
          _hiddenAnswers = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Check if quiz is complete
    if (quizProvider.isQuizComplete) {
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
        actions: [
          // Power-up buttons in app bar
          IconButton(
            icon: SizedBox(
              width: 32,
              height: 32,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.remove_circle, color: Colors.orange ),
                  if (_fiftyFiftyCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$_fiftyFiftyCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            onPressed: _fiftyFiftyCount > 0 && !_fiftyFiftyUsed ? _useFiftyFifty : null,
            tooltip: '50/50 ($_fiftyFiftyCount left)',
          ),
          IconButton(
            icon: SizedBox(
              width: 32,
              height: 32,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.skip_next, color: Colors.blue),
                  if (_skipCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$_skipCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            onPressed: _skipCount > 0 ? _useSkip : null,
            tooltip: 'Skip ($_skipCount left)',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Power-ups description
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple, width: 2),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stars, color: Colors.purple),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Use power-ups in the top right!',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
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
            ).where((entry) => !_hiddenAnswers.contains(entry.key)).map<Widget>((entry) {
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
