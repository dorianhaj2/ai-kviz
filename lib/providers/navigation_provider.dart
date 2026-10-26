import 'package:flutter/foundation.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }


  void navigateToHome() => setIndex(0);

  void navigateToLeaderboard() => setIndex(1);

  void navigateToProfile() => setIndex(2);

  void reset() => setIndex(0);
}
