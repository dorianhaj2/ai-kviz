/// Application-wide constants
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  static const double similarityThreshold = 0.9;

  /// Default values for guest users
  static const String defaultUsername = 'Guest';
  static const String defaultEmail = 'guest@example.com';
  static const String defaultUserId = '';

  static const String userDataCollection = 'UserData';

  static const Duration answerFeedbackDuration = Duration(seconds: 1);
}
