import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/achievement_model.dart';
import '../models/achievement_definitions.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

/// Service for managing achievements
class AchievementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Logger? _logger;

  AchievementService({Logger? logger}) : _logger = logger;

  /// Gets all achievements for a user with unlock status
  Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      _logger?.d('Fetching achievements for user: $userId');

      final doc = await _db
          .collection(AppConstants.userDataCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        _logger?.w('User not found: $userId');
        return AchievementDefinitions.all;
      }

      final data = doc.data();
      final unlockedAchievements =
          (data?['achievements'] as List<dynamic>?) ?? [];

      // Map unlocked achievements with their unlock times
      final Map<String, DateTime> unlockedMap = {};
      for (final achievement in unlockedAchievements) {
        if (achievement is Map<String, dynamic>) {
          final id = achievement['id'] as String?;
          final unlockedAt = achievement['unlocked_at'] as String?;
          if (id != null && unlockedAt != null) {
            unlockedMap[id] = DateTime.parse(unlockedAt);
          }
        }
      }

      // Return all achievements with unlock status
      return AchievementDefinitions.all.map((achievement) {
        if (unlockedMap.containsKey(achievement.id)) {
          return achievement.withUnlockTime(unlockedMap[achievement.id]);
        }
        return achievement;
      }).toList();
    } catch (e) {
      _logger?.e('Failed to fetch achievements: $e');
      rethrow;
    }
  }

  /// Checks and unlocks achievements based on user stats
  /// Returns list of newly unlocked achievements
  Future<List<Achievement>> checkAndUnlockAchievements({
    required String userId,
    required User user,
    int? quizScore,
    int? quizTotalQuestions,
    int? previousRating,
    bool? previousQuizWasLoss,
  }) async {
    try {
      _logger?.d('Checking achievements for user: $userId');

      final currentAchievements = await getUserAchievements(userId);
      final List<Achievement> newlyUnlocked = [];

      // Get currently unlocked achievement IDs
      final unlockedIds = currentAchievements
          .where((a) => a.isUnlocked)
          .map((a) => a.id)
          .toSet();

      // Check quiz completion achievements
      _checkQuizAchievements(user.quizzesCompleted, unlockedIds, newlyUnlocked);

      // Check score achievements (if quiz just completed)
      if (quizScore != null && quizTotalQuestions != null) {
        _checkScoreAchievements(
          quizScore,
          quizTotalQuestions,
          user.totalCorrect,
          unlockedIds,
          newlyUnlocked,
        );
      }

      // Check rating achievements
      _checkRatingAchievements(user.rating, unlockedIds, newlyUnlocked);

      // Check special achievements
      if (previousQuizWasLoss == true &&
          quizScore != null &&
          quizTotalQuestions != null) {
        final percentage = quizScore / quizTotalQuestions;
        if (percentage > 0.5 && !unlockedIds.contains('comeback')) {
          final achievement = AchievementDefinitions.getById('comeback');
          if (achievement != null) {
            newlyUnlocked.add(achievement.unlock());
          }
        }
      }

      // Save newly unlocked achievements
      if (newlyUnlocked.isNotEmpty) {
        await _saveUnlockedAchievements(userId, newlyUnlocked);
      }

      _logger?.i('Unlocked ${newlyUnlocked.length} new achievements');
      return newlyUnlocked;
    } catch (e) {
      _logger?.e('Failed to check achievements: $e');
      rethrow;
    }
  }

  void _checkQuizAchievements(
    int quizzesCompleted,
    Set<String> unlockedIds,
    List<Achievement> newlyUnlocked,
  ) {
    final quizMilestones = {
      'first_quiz': 1,
      'quiz_5': 5,
      'quiz_10': 10,
      'quiz_25': 25,
      'quiz_50': 50,
      'quiz_100': 100,
    };

    for (final entry in quizMilestones.entries) {
      if (quizzesCompleted >= entry.value && !unlockedIds.contains(entry.key)) {
        final achievement = AchievementDefinitions.getById(entry.key);
        if (achievement != null) {
          newlyUnlocked.add(achievement.unlock());
        }
      }
    }
  }

  void _checkScoreAchievements(
    int score,
    int totalQuestions,
    int totalCorrect,
    Set<String> unlockedIds,
    List<Achievement> newlyUnlocked,
  ) {
    final percentage = totalQuestions > 0 ? score / totalQuestions : 0.0;
    final isPerfect = score == totalQuestions && totalQuestions > 0;

    // Perfect score achievement
    if (isPerfect && !unlockedIds.contains('perfect_first')) {
      final achievement = AchievementDefinitions.getById('perfect_first');
      if (achievement != null) {
        newlyUnlocked.add(achievement.unlock());
      }
    }

    // Score threshold achievements
    if (percentage >= 0.8 && !unlockedIds.contains('score_80')) {
      final achievement = AchievementDefinitions.getById('score_80');
      if (achievement != null) {
        newlyUnlocked.add(achievement.unlock());
      }
    }

    if (percentage >= 0.9 && !unlockedIds.contains('score_90')) {
      final achievement = AchievementDefinitions.getById('score_90');
      if (achievement != null) {
        newlyUnlocked.add(achievement.unlock());
      }
    }

    // Correct answers milestones
    final correctMilestones = {
      'correct_50': 50,
      'correct_100': 100,
      'correct_500': 500,
      'correct_1000': 1000,
    };

    for (final entry in correctMilestones.entries) {
      if (totalCorrect >= entry.value && !unlockedIds.contains(entry.key)) {
        final achievement = AchievementDefinitions.getById(entry.key);
        if (achievement != null) {
          newlyUnlocked.add(achievement.unlock());
        }
      }
    }
  }

  void _checkRatingAchievements(
    int rating,
    Set<String> unlockedIds,
    List<Achievement> newlyUnlocked,
  ) {
    final ratingMilestones = {
      'rating_1100': 1100,
      'rating_1200': 1200,
      'rating_1500': 1500,
      'rating_2000': 2000,
    };

    for (final entry in ratingMilestones.entries) {
      if (rating >= entry.value && !unlockedIds.contains(entry.key)) {
        final achievement = AchievementDefinitions.getById(entry.key);
        if (achievement != null) {
          newlyUnlocked.add(achievement.unlock());
        }
      }
    }
  }

  Future<void> _saveUnlockedAchievements(
    String userId,
    List<Achievement> newAchievements,
  ) async {
    try {
      final achievementsData = newAchievements.map((a) => a.toMap()).toList();

      await _db.collection(AppConstants.userDataCollection).doc(userId).update({
        'achievements': FieldValue.arrayUnion(achievementsData),
      });

      _logger?.i('Saved ${newAchievements.length} achievements for user');
    } catch (e) {
      _logger?.e('Failed to save achievements: $e');
      rethrow;
    }
  }

  /// Gets the count of unlocked achievements for a user
  Future<int> getUnlockedCount(String userId) async {
    final achievements = await getUserAchievements(userId);
    return achievements.where((a) => a.isUnlocked).length;
  }

  /// Gets achievement progress statistics
  Future<Map<String, dynamic>> getAchievementStats(String userId) async {
    final achievements = await getUserAchievements(userId);
    final unlocked = achievements.where((a) => a.isUnlocked).toList();

    return {
      'total': achievements.length,
      'unlocked': unlocked.length,
      'percentage': (unlocked.length / achievements.length * 100).round(),
      'byRarity': {
        'common': unlocked
            .where((a) => a.rarity == AchievementRarity.common)
            .length,
        'rare': unlocked
            .where((a) => a.rarity == AchievementRarity.rare)
            .length,
        'epic': unlocked
            .where((a) => a.rarity == AchievementRarity.epic)
            .length,
        'legendary': unlocked
            .where((a) => a.rarity == AchievementRarity.legendary)
            .length,
      },
    };
  }
}
