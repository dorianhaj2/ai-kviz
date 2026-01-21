import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

/// Service for handling leaderboard operations
class LeaderboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Logger? _logger;

  LeaderboardService({Logger? logger}) : _logger = logger;

  /// Gets the top players sorted by rating
  ///
  /// [limit] - Maximum number of players to return (default: 50)
  Future<List<User>> getTopPlayers({int limit = 50}) async {
    try {
      _logger?.d('Fetching top $limit players from leaderboard');

      final snapshot = await _db
          .collection(AppConstants.userDataCollection)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      final players = snapshot.docs.map((doc) {
        return User.fromFirestore(doc.id, doc.data());
      }).toList();

      _logger?.i('Found ${players.length} players for leaderboard');
      return players;
    } catch (e) {
      _logger?.e('Failed to fetch leaderboard: $e');
      rethrow;
    }
  }

  /// Gets a user's rank in the leaderboard
  ///
  /// Returns the rank (1-based) or null if user not found
  Future<int?> getUserRank(String userId) async {
    try {
      _logger?.d('Fetching rank for user: $userId');

      // Get user's rating first
      final userDoc = await _db
          .collection(AppConstants.userDataCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        _logger?.w('User not found: $userId');
        return null;
      }

      final userRating = userDoc.data()?['rating'] as int? ?? 1000;

      // Count users with higher rating
      final higherRatedSnapshot = await _db
          .collection(AppConstants.userDataCollection)
          .where('rating', isGreaterThan: userRating)
          .count()
          .get();

      final rank = (higherRatedSnapshot.count ?? 0) + 1;
      _logger?.i('User $userId is ranked #$rank');
      return rank;
    } catch (e) {
      _logger?.e('Failed to get user rank: $e');
      rethrow;
    }
  }

  /// Gets players around a specific user (for context)
  ///
  /// Returns players ranked just above and below the given user
  Future<List<User>> getPlayersAroundUser(
    String userId, {
    int range = 5,
  }) async {
    try {
      _logger?.d('Fetching players around user: $userId');

      // Get user's rating first
      final userDoc = await _db
          .collection(AppConstants.userDataCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        _logger?.w('User not found: $userId');
        return [];
      }

      final userRating = userDoc.data()?['rating'] as int? ?? 1000;

      // Get players with higher rating
      final higherRatedSnapshot = await _db
          .collection(AppConstants.userDataCollection)
          .where('rating', isGreaterThan: userRating)
          .orderBy('rating', descending: false)
          .limit(range)
          .get();

      // Get players with lower or equal rating (excluding self)
      final lowerRatedSnapshot = await _db
          .collection(AppConstants.userDataCollection)
          .where('rating', isLessThanOrEqualTo: userRating)
          .orderBy('rating', descending: true)
          .limit(range + 1)
          .get();

      final List<User> players = [];

      // Add higher rated players (in descending order)
      players.addAll(
        higherRatedSnapshot.docs.reversed.map((doc) {
          return User.fromFirestore(doc.id, doc.data());
        }),
      );

      // Add lower rated players
      players.addAll(
        lowerRatedSnapshot.docs.map((doc) {
          return User.fromFirestore(doc.id, doc.data());
        }),
      );

      _logger?.i('Found ${players.length} players around user');
      return players;
    } catch (e) {
      _logger?.e('Failed to get players around user: $e');
      rethrow;
    }
  }

  /// Updates a user's rating in Firestore
  Future<void> updateUserRating(String userId, int newRating) async {
    try {
      _logger?.d('Updating rating for user $userId to $newRating');

      await _db.collection(AppConstants.userDataCollection).doc(userId).update({
        'rating': newRating,
      });

      _logger?.i('Successfully updated rating for user $userId');
    } catch (e) {
      _logger?.e('Failed to update user rating: $e');
      rethrow;
    }
  }

  /// Gets the total number of players
  Future<int> getTotalPlayers() async {
    try {
      final count = await _db
          .collection(AppConstants.userDataCollection)
          .count()
          .get();

      return count.count ?? 0;
    } catch (e) {
      _logger?.e('Failed to get total players: $e');
      rethrow;
    }
  }

  /// Stream of top players for real-time updates
  Stream<List<User>> watchTopPlayers({int limit = 50}) {
    return _db
        .collection(AppConstants.userDataCollection)
        .orderBy('rating', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return User.fromFirestore(doc.id, doc.data());
          }).toList();
        });
  }
}
