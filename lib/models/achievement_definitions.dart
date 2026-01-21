import 'package:flutter/material.dart';
import 'achievement_model.dart';

/// Defines all available achievements in the app
class AchievementDefinitions {
  AchievementDefinitions._();

  /// All achievement definitions
  static final List<Achievement> all = [
    // Quiz completion achievements
    const Achievement(
      id: 'first_quiz',
      name: 'First Steps',
      description: 'Complete your first quiz',
      icon: Icons.play_arrow,
      category: AchievementCategory.quizzes,
      rarity: AchievementRarity.common,
    ),
    const Achievement(
      id: 'quiz_5',
      name: 'Getting Started',
      description: 'Complete 5 quizzes',
      icon: Icons.school,
      category: AchievementCategory.quizzes,
      rarity: AchievementRarity.common,
    ),
    const Achievement(
      id: 'quiz_10',
      name: 'Quiz Enthusiast',
      description: 'Complete 10 quizzes',
      icon: Icons.auto_stories,
      category: AchievementCategory.quizzes,
      rarity: AchievementRarity.rare,
    ),
    const Achievement(
      id: 'quiz_25',
      name: 'Knowledge Seeker',
      description: 'Complete 25 quizzes',
      icon: Icons.psychology,
      category: AchievementCategory.quizzes,
      rarity: AchievementRarity.rare,
    ),
    const Achievement(
      id: 'quiz_50',
      name: 'Quiz Master',
      description: 'Complete 50 quizzes',
      icon: Icons.workspace_premium,
      category: AchievementCategory.quizzes,
      rarity: AchievementRarity.epic,
    ),
    const Achievement(
      id: 'quiz_100',
      name: 'Quiz Legend',
      description: 'Complete 100 quizzes',
      icon: Icons.military_tech,
      category: AchievementCategory.quizzes,
      rarity: AchievementRarity.legendary,
    ),

    // Perfect score achievements
    const Achievement(
      id: 'perfect_first',
      name: 'Flawless',
      description: 'Get a perfect score on a quiz',
      icon: Icons.check_circle,
      category: AchievementCategory.scores,
      rarity: AchievementRarity.rare,
    ),
    const Achievement(
      id: 'perfect_5',
      name: 'Perfectionist',
      description: 'Get 5 perfect scores',
      icon: Icons.verified,
      category: AchievementCategory.scores,
      rarity: AchievementRarity.epic,
    ),
    const Achievement(
      id: 'perfect_10',
      name: 'Unstoppable',
      description: 'Get 10 perfect scores',
      icon: Icons.diamond,
      category: AchievementCategory.scores,
      rarity: AchievementRarity.legendary,
    ),

    // Score threshold achievements
    const Achievement(
      id: 'score_80',
      name: 'High Achiever',
      description: 'Achieve 80% or higher on a quiz',
      icon: Icons.trending_up,
      category: AchievementCategory.scores,
      rarity: AchievementRarity.common,
    ),
    const Achievement(
      id: 'score_90',
      name: 'Excellence',
      description: 'Achieve 90% or higher on a quiz',
      icon: Icons.star,
      category: AchievementCategory.scores,
      rarity: AchievementRarity.rare,
    ),

    // Rating achievements
    const Achievement(
      id: 'rating_1100',
      name: 'Rising Star',
      description: 'Reach a rating of 1100',
      icon: Icons.arrow_upward,
      category: AchievementCategory.rating,
      rarity: AchievementRarity.common,
    ),
    const Achievement(
      id: 'rating_1200',
      name: 'Competitor',
      description: 'Reach a rating of 1200',
      icon: Icons.emoji_events,
      category: AchievementCategory.rating,
      rarity: AchievementRarity.rare,
    ),
    const Achievement(
      id: 'rating_1500',
      name: 'Expert',
      description: 'Reach a rating of 1500',
      icon: Icons.shield,
      category: AchievementCategory.rating,
      rarity: AchievementRarity.epic,
    ),
    const Achievement(
      id: 'rating_2000',
      name: 'Grandmaster',
      description: 'Reach a rating of 2000',
      icon: Icons.whatshot,
      category: AchievementCategory.rating,
      rarity: AchievementRarity.legendary,
    ),

    // Correct answers achievements
    const Achievement(
      id: 'correct_50',
      name: 'Quick Learner',
      description: 'Answer 50 questions correctly',
      icon: Icons.lightbulb,
      category: AchievementCategory.scores,
      rarity: AchievementRarity.common,
    ),
    const Achievement(
      id: 'correct_100',
      name: 'Knowledgeable',
      description: 'Answer 100 questions correctly',
      icon: Icons.local_library,
      category: AchievementCategory.scores,
      rarity: AchievementRarity.rare,
    ),
    const Achievement(
      id: 'correct_500',
      name: 'Walking Encyclopedia',
      description: 'Answer 500 questions correctly',
      icon: Icons.menu_book,
      category: AchievementCategory.scores,
      rarity: AchievementRarity.epic,
    ),
    const Achievement(
      id: 'correct_1000',
      name: 'Genius',
      description: 'Answer 1000 questions correctly',
      icon: Icons.psychology_alt,
      category: AchievementCategory.scores,
      rarity: AchievementRarity.legendary,
    ),

    // Special achievements
    const Achievement(
      id: 'comeback',
      name: 'Comeback King',
      description: 'Win a quiz after losing rating in the previous one',
      icon: Icons.replay,
      category: AchievementCategory.special,
      rarity: AchievementRarity.rare,
    ),
    const Achievement(
      id: 'dedicated',
      name: 'Dedicated',
      description: 'Complete 5 quizzes in a single day',
      icon: Icons.calendar_today,
      category: AchievementCategory.special,
      rarity: AchievementRarity.epic,
    ),
  ];

  /// Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get achievements by category
  static List<Achievement> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }

  /// Get achievements by rarity
  static List<Achievement> getByRarity(AchievementRarity rarity) {
    return all.where((a) => a.rarity == rarity).toList();
  }
}
