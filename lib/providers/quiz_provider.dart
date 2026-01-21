import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import '../models/quiz_result.dart';
import '../models/game_mode.dart';

/// Provider for managing quiz state throughout the application
class QuizProvider with   ChangeNotifier {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  String _currentTopic = '';
  String _currentDifficulty = '';
  bool _isLoading = false;
  GameMode _gameMode = GameMode.normal;
  
  // Survival mode specific
  int _streak = 0;
  int _maxStreak = 0;
  
  // Timed mode specific
  int _questionsAnsweredInTime = 0;

  // Getters
  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  String get currentTopic => _currentTopic;
  String get currentDifficulty => _currentDifficulty;
  bool get isLoading => _isLoading;
  GameMode get gameMode => _gameMode;
  int get streak => _streak;
  int get maxStreak => _maxStreak;
  int get questionsAnsweredInTime => _questionsAnsweredInTime;

  Question? get currentQuestion {
    if (_currentQuestionIndex < _questions.length) {
      return _questions[_currentQuestionIndex];
    }
    return null;
  }

  bool get isQuizComplete => _currentQuestionIndex >= _questions.length;
  int get totalQuestions => _questions.length;
  int get questionsRemaining => _questions.length - _currentQuestionIndex;

  /// Sets loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Initializes a new quiz with questions
  void initializeQuiz(
    List<Question> questions, {
    String topic = '',
    String difficulty = '',
    GameMode gameMode = GameMode.normal,
  }) {
    _questions = questions;
    _currentQuestionIndex = 0;
    _score = 0;
    _currentTopic = topic;
    _currentDifficulty = difficulty;
    _isLoading = false;
    _gameMode = gameMode;
    _streak = 0;
    _maxStreak = 0;
    _questionsAnsweredInTime = 0;
    notifyListeners();
  }

  /// Sets questions without resetting other state
  void setQuestions(List<Question> questions) {
    _questions = questions;
    notifyListeners();
  }

  /// Answers the current question and moves to next
  void answerQuestion(bool isCorrect) {
    if (isCorrect) {
      _score++;
      _streak++;
      if (_streak > _maxStreak) {
        _maxStreak = _streak;
      }
    } else {
      _streak = 0;
    }
    
    // For timed mode, track questions answered
    if (_gameMode == GameMode.timed) {
      _questionsAnsweredInTime++;
    }
    
    _currentQuestionIndex++;
    notifyListeners();
  }
  
  /// Check if survival mode should end (wrong answer)
  bool shouldEndSurvival(bool isCorrect) {
    return _gameMode == GameMode.survival && !isCorrect;
  }
  
  /// Add more questions (for timed mode)
  void addQuestions(List<Question> newQuestions) {
    _questions.addAll(newQuestions);
    notifyListeners();
  }

  /// Resets the quiz to initial state
  void resetQuiz() {
    _currentQuestionIndex = 0;
    _score = 0;
    _questions = [];
    _currentTopic = '';
    _currentDifficulty = '';
    _isLoading = false;
    _gameMode = GameMode.normal;
    _streak = 0;
    _maxStreak = 0;
    _questionsAnsweredInTime = 0;
    notifyListeners();
  }

  /// Gets the quiz result
  QuizResult getResult() {
    return QuizResult(
      score: _score,
      totalQuestions: _questions.length,
      completedAt: DateTime.now(),
      topic: _currentTopic,
    );
  }

  /// Gets the current progress as a percentage (0.0 to 1.0)
  double get progress {
    if (_questions.isEmpty) return 0.0;
    return _currentQuestionIndex / _questions.length;
  }

  /// Gets the current score as a percentage
  double get scorePercentage {
    if (_questions.isEmpty) return 0.0;
    return (_score / _questions.length) * 100;
  }
}
