import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// Provider for managing user state throughout the application
class UserProvider with ChangeNotifier {
  User _currentUser = User.guest();

  User get currentUser => _currentUser;

  /// Alias for currentUser for convenience
  User? get user => _currentUser.id.isEmpty ? null : _currentUser;

  String get username => _currentUser.username;
  String get email => _currentUser.email;
  String get userId => _currentUser.id;
  bool get isAdmin => _currentUser.isAdmin;
  int get quizzesCompleted => _currentUser.quizzesCompleted;
  int get totalCorrect => _currentUser.totalCorrect;
  int get totalAnswers => _currentUser.totalAnswers;
  double get averageScore => _currentUser.averageScore;
  int get rating => _currentUser.rating;

  bool get isGuest => _currentUser.id.isEmpty;
  bool get isLoggedIn => _currentUser.id.isNotEmpty;

  /// Sets the current user
  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Updates user with a new User object (for convenience)
  void setUserFromUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Updates user with new data
  void updateUser({
    String? username,
    String? email,
    int? quizzesCompleted,
    int? totalCorrect,
    int? totalAnswers,
    double? averageScore,
    bool? isAdmin,
    int? rating,
  }) {
    _currentUser = _currentUser.copyWith(
      username: username,
      email: email,
      quizzesCompleted: quizzesCompleted,
      totalCorrect: totalCorrect,
      totalAnswers: totalAnswers,
      averageScore: averageScore,
      isAdmin: isAdmin,
      rating: rating,
    );
    notifyListeners();
  }

  /// Increments quiz statistics after completing a quiz
  /// Also updates rating based on performance
  void completeQuiz({required int score, required int totalQuestions}) {
    final newQuizzesCompleted = _currentUser.quizzesCompleted + 1;
    final newTotalAnswers = _currentUser.totalAnswers + totalQuestions;
    final newTotalCorrect = _currentUser.totalCorrect + score;
    final newAverageScore = newTotalCorrect / newTotalAnswers;

    // Calculate rating change based on performance
    final newRating = calculateNewRating(
      currentRating: _currentUser.rating,
      score: score,
      totalQuestions: totalQuestions,
    );

    _currentUser = _currentUser.copyWith(
      quizzesCompleted: newQuizzesCompleted,
      totalAnswers: newTotalAnswers,
      totalCorrect: newTotalCorrect,
      averageScore: newAverageScore,
      rating: newRating,
    );
    notifyListeners();
  }

  /// Calculates the new rating based on quiz performance
  /// Players gain points if they answer more than half correctly
  /// Players lose points if they answer less than half correctly
  int calculateNewRating({
    required int currentRating,
    required int score,
    required int totalQuestions,
  }) {
    if (totalQuestions == 0) return currentRating;

    final double percentage = score / totalQuestions;
    final double halfThreshold = 0.5;

    // Base points for calculation (scales with quiz size)
    final int basePoints = 10 + (totalQuestions ~/ 2);

    int ratingChange;

    if (percentage > halfThreshold) {
      // Gain points: the more correct, the more points
      // Performance factor: 0 at 50%, 1 at 100%
      final double performanceFactor =
          (percentage - halfThreshold) / halfThreshold;
      ratingChange = (basePoints * performanceFactor * 2).round();

      // Bonus for perfect score
      if (percentage == 1.0) {
        ratingChange += 5;
      }
    } else if (percentage < halfThreshold) {
      // Lose points: the fewer correct, the more points lost
      // Performance factor: 0 at 50%, -1 at 0%
      final double performanceFactor =
          (halfThreshold - percentage) / halfThreshold;
      ratingChange = -(basePoints * performanceFactor * 1.5).round();
    } else {
      // Exactly 50% - no change
      ratingChange = 0;
    }

    // Ensure rating doesn't go below 0
    final newRating = (currentRating + ratingChange).clamp(0, 99999);
    return newRating;
  }

  /// Gets the rating change that would occur for a given quiz result
  int getRatingChange({required int score, required int totalQuestions}) {
    final newRating = calculateNewRating(
      currentRating: _currentUser.rating,
      score: score,
      totalQuestions: totalQuestions,
    );
    return newRating - _currentUser.rating;
  }

  /// Resets user to guest
  void logout() {
    _currentUser = User.guest();
    notifyListeners();
  }

  /// Gets user statistics as a map
  Map<String, dynamic> getStatistics() {
    return {
      'quizzes': _currentUser.quizzesCompleted,
      'avg_score': _currentUser.averageScore,
      'total_correct': _currentUser.totalCorrect,
      'total_answers': _currentUser.totalAnswers,
      'rating': _currentUser.rating,
    };
  }
}
