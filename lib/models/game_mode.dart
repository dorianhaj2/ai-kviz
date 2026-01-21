import 'package:flutter/material.dart';

/// Enum representing different game modes available in the quiz
enum GameMode {
  normal,
  timed,
  survival,
  arcade,
}

/// Extension to provide user-friendly names and descriptions for game modes
extension GameModeExtension on GameMode {
  /// Display name for the game mode
  String get name {
    switch (this) {
      case GameMode.normal:
        return 'Normal';
      case GameMode.timed:
        return 'Timed';
      case GameMode.survival:
        return 'Survival';
      case GameMode.arcade:
        return 'Arcade';
    }
  }

  /// Description of the game mode
  String get description {
    switch (this) {
      case GameMode.normal:
        return 'Classic quiz mode with fixed questions';
      case GameMode.timed:
        return 'Answer as many questions as you can in 60 seconds';
      case GameMode.survival:
        return 'Answer correctly in a row. One wrong answer and you lose!';
      case GameMode.arcade:
        return 'Classic mode with power-ups to help you';
    }
  }

  /// Icon representing the game mode
  IconData get icon {
    switch (this) {
      case GameMode.normal:
        return Icons.quiz;
      case GameMode.timed:
        return Icons.timer;
      case GameMode.survival:
        return Icons.favorite;
      case GameMode.arcade:
        return Icons.games;
    }
  }

  /// Color theme for the game mode
  Color get color {
    switch (this) {
      case GameMode.normal:
        return Colors.blue;
      case GameMode.timed:
        return Colors.orange;
      case GameMode.survival:
        return Colors.red;
      case GameMode.arcade:
        return Colors.purple;
    }
  }
}
