import 'dart:async';
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
import '../services/question_service.dart';
import '../models/achievement_model.dart';
import '../service_locator.dart';

/// Timed Quiz Mode - Answer as many questions as possible in 60 seconds
class TimedQuiz extends StatefulWidget {
  const TimedQuiz({Key? key}) : super(key: key);

  @override
  State<TimedQuiz> createState() => _TimedQuizState();
}

class _TimedQuizState extends State<TimedQuiz> {
  String? selectedAnswerIndex;
  bool answerClicked = false;
  int? _ratingChange;
  bool _statsUpdated = false;
  int? _lastQuestionIndex;
  List<MapEntry<String, bool>>? _shuffledAnswers;
  List<Achievement> _newAchievements = [];
  
  // Timer specific
  static const int _timerDuration = 60; // 60 seconds
  int _remainingSeconds = _timerDuration;
  Timer? _timer;
  bool _timeUp = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _preloadMoreQuestions(); // Load more questions in advance
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _timeUp = true;
        });
      }
    });
  }

  Future<void> _preloadMoreQuestions() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    
    try {
      final questionService = getIt<QuestionService>();
      final newQuestions = await questionService.initializeQuestions(
        quizProvider.currentTopic,
        difficulty: quizProvider.currentDifficulty,
      );
      quizProvider.addQuestions(newQuestions);
    } catch (e) {
      debugPrint('Failed to load more questions: $e');
    }
    
  }

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
    if (answerClicked || _timeUp) return;

    setState(() {
      selectedAnswerIndex = index;
      answerClicked = true;
    });

    Future.delayed(AppConstants.answerFeedbackDuration, () {
      if (mounted && !_timeUp) {
        final quizProvider = Provider.of<QuizProvider>(context, listen: false);
        quizProvider.answerQuestion(isCorrect);

        setState(() {
          selectedAnswerIndex = null;
          answerClicked = false;
        });

        // Preload more questions every 10 questions
        if (quizProvider.questionsAnsweredInTime % 10 == 0) {
          _preloadMoreQuestions();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Check if time is up
    if (_timeUp) {
      _timer?.cancel();
      
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
        questionsAnswered: quizProvider.questionsAnsweredInTime,
      );
    }

    final currentQuestion = quizProvider.currentQuestion;
    if (currentQuestion == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryButton,
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
            Text("Score: ${quizProvider.score}"),
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  "$_remainingSeconds",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _remainingSeconds <= 10 ? Colors.red : Colors.white,
                  ),
                ),
              ],
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
