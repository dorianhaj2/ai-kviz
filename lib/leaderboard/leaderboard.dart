import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../services/leaderboard_service.dart';
import '../service_locator.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late final LeaderboardService _leaderboardService;
  List<User> _players = [];
  bool _isLoading = true;
  String? _error;
  int? _currentUserRank;

  @override
  void initState() {
    super.initState();
    _leaderboardService = getIt<LeaderboardService>();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final players = await _leaderboardService.getTopPlayers(limit: 100);

      // Get current user's rank if logged in
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isLoggedIn) {
        _currentUserRank = await _leaderboardService.getUserRank(
          userProvider.userId,
        );
      }

      setState(() {
        _players = players;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load leaderboard: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Header
          const Text(
            'Leaderboard',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Top Players Ranked by Rating',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
          ),
          const SizedBox(height: 16),

          // Current user's rank card (if logged in)
          if (userProvider.isLoggedIn && _currentUserRank != null)
            _buildCurrentUserCard(userProvider),

          const SizedBox(height: 16),

          // Leaderboard content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildCurrentUserCard(UserProvider userProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryButton.withOpacity(0.8),
            AppColors.primaryButton.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryButton.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$_currentUserRank',
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Rank',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  userProvider.username,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Rating',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${userProvider.rating}',
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryButton),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.primaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLeaderboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_players.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              color: AppColors.secondaryText,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No players yet',
              style: TextStyle(color: AppColors.primaryText, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to complete a quiz!',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      color: AppColors.primaryButton,
      backgroundColor: AppColors.cardBackground,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _players.length,
        itemBuilder: (context, index) {
          final player = _players[index];
          final rank = index + 1;
          return _LeaderboardTile(
            player: player,
            rank: rank,
            isCurrentUser:
                player.id ==
                Provider.of<UserProvider>(context, listen: false).userId,
          );
        },
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final User player;
  final int rank;
  final bool isCurrentUser;

  const _LeaderboardTile({
    required this.player,
    required this.rank,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primaryButton.withOpacity(0.2)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: AppColors.primaryButton, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Rank
          _buildRankWidget(),
          const SizedBox(width: 16),

          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        player.username,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 16,
                          fontWeight: isCurrentUser
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryButton,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${player.quizzesCompleted} quizzes completed',
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Rating
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: _getRatingColor(), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${player.rating}',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                _getRankTitle(),
                style: TextStyle(
                  color: _getRatingColor(),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankWidget() {
    if (rank <= 3) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: _getMedalColors(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _getMedalColors()[0].withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            rank == 1 ? Icons.emoji_events : Icons.workspace_premium,
            color: Colors.white,
            size: 18,
          ),
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.buttonBackground,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<Color> _getMedalColors() {
    switch (rank) {
      case 1:
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)]; // Gold
      case 2:
        return [const Color(0xFFC0C0C0), const Color(0xFF808080)]; // Silver
      case 3:
        return [const Color(0xFFCD7F32), const Color(0xFF8B4513)]; // Bronze
      default:
        return [AppColors.buttonBackground, AppColors.buttonBackground];
    }
  }


  Color _getRatingColor() {
    if (player.rating >= 2000) return const Color(0xFFFFD700); // Gold
    if (player.rating >= 1500) return const Color(0xFFC0C0C0); // Silver
    if (player.rating >= 1200) return const Color(0xFFCD7F32); // Bronze
    return AppColors.secondaryText;
  }

  String _getRankTitle() {
    if (player.rating >= 2000) return 'Master';
    if (player.rating >= 1500) return 'Expert';
    if (player.rating >= 1200) return 'Advanced';
    if (player.rating >= 1000) return 'Intermediate';
    return 'Beginner';
  }
}
