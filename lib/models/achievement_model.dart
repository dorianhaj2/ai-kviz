import 'package:flutter/material.dart';

/// Represents an achievement that can be unlocked by players
class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.rarity = AchievementRarity.common,
    this.unlockedAt,
  });

  /// Creates a copy with unlocked timestamp
  Achievement unlock() {
    return Achievement(
      id: id,
      name: name,
      description: description,
      icon: icon,
      category: category,
      rarity: rarity,
      unlockedAt: DateTime.now(),
    );
  }

  /// Creates achievement with specific unlock time
  Achievement withUnlockTime(DateTime? time) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      icon: icon,
      category: category,
      rarity: rarity,
      unlockedAt: time,
    );
  }

  bool get isUnlocked => unlockedAt != null;

  /// Converts to map for storage
  Map<String, dynamic> toMap() {
    return {'id': id, 'unlocked_at': unlockedAt?.toIso8601String()};
  }
}

/// Achievement categories
enum AchievementCategory { quizzes, scores, rating, streaks, special }

/// Achievement rarity levels
enum AchievementRarity { common, rare, epic, legendary }

/// Extension for rarity colors
extension AchievementRarityExtension on AchievementRarity {
  Color get color {
    switch (this) {
      case AchievementRarity.common:
        return const Color(0xFF9E9E9E); // Grey
      case AchievementRarity.rare:
        return const Color(0xFF2196F3); // Blue
      case AchievementRarity.epic:
        return const Color(0xFF9C27B0); // Purple
      case AchievementRarity.legendary:
        return const Color(0xFFFFD700); // Gold
    }
  }

  String get label {
    switch (this) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }
}

/// Extension for category labels
extension AchievementCategoryExtension on AchievementCategory {
  String get label {
    switch (this) {
      case AchievementCategory.quizzes:
        return 'Quizzes';
      case AchievementCategory.scores:
        return 'Scores';
      case AchievementCategory.rating:
        return 'Rating';
      case AchievementCategory.streaks:
        return 'Streaks';
      case AchievementCategory.special:
        return 'Special';
    }
  }

  IconData get icon {
    switch (this) {
      case AchievementCategory.quizzes:
        return Icons.quiz;
      case AchievementCategory.scores:
        return Icons.score;
      case AchievementCategory.rating:
        return Icons.leaderboard;
      case AchievementCategory.streaks:
        return Icons.local_fire_department;
      case AchievementCategory.special:
        return Icons.star;
    }
  }
}
