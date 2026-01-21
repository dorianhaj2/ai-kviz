import 'package:flutter/foundation.dart';

/// Provider for managing navigation state
class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  /// Sets the current navigation index
  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Navigates to home screen
  void navigateToHome() => setIndex(0);

  /// Navigates to leaderboard screen
  void navigateToLeaderboard() => setIndex(1);

  /// Navigates to profile screen
  void navigateToProfile() => setIndex(2);

  /// Resets navigation to home
  void reset() => setIndex(0);
}
