import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/achievement_model.dart';
import '../models/achievement_definitions.dart';
import '../services/achievement_service.dart';
import '../service_locator.dart';
import '../providers/user_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late final AchievementService _achievementService;
  List<Achievement> _achievements = [];
  bool _isLoading = true;
  String? _error;
  AchievementCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _achievementService = getIt<AchievementService>();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.isLoggedIn) {
      setState(() {
        _achievements = AchievementDefinitions.all;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final achievements = await _achievementService.getUserAchievements(
        userProvider.userId,
      );
      setState(() {
        _achievements = achievements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load achievements: $e';
        _isLoading = false;
      });
    }
  }

  List<Achievement> get _filteredAchievements {
    if (_selectedCategory == null) {
      return _achievements;
    }
    return _achievements.where((a) => a.category == _selectedCategory).toList();
  }

  int get _unlockedCount => _achievements.where((a) => a.isUnlocked).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.primaryText,
      ),
      body: Column(
        children: [
          // Progress header
          _buildProgressHeader(),

          // Category filter
          _buildCategoryFilter(),

          // Achievements list
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    final total = _achievements.length;
    final unlocked = _unlockedCount;
    final progress = total > 0 ? unlocked / total : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Progress',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$unlocked / $total',
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Rarity breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: AchievementRarity.values.map((rarity) {
              final count = _achievements
                  .where((a) => a.rarity == rarity && a.isUnlocked)
                  .length;
              final total = _achievements
                  .where((a) => a.rarity == rarity)
                  .length;
              return _buildRarityBadge(rarity, count, total);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRarityBadge(AchievementRarity rarity, int count, int total) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: rarity.color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: rarity.color, width: 2),
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(
                color: rarity.color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(rarity.label, style: TextStyle(color: rarity.color, fontSize: 10)),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(null, 'All'),
          ...AchievementCategory.values.map((category) {
            return _buildFilterChip(category, category.label);
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(AchievementCategory? category, String label) {
    final isSelected = _selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        backgroundColor: AppColors.cardBackground,
        selectedColor: AppColors.primaryButton,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.secondaryText,
        ),
        checkmarkColor: Colors.white,
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
              onPressed: _loadAchievements,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredAchievements = _filteredAchievements;

    // Sort: unlocked first, then by rarity
    filteredAchievements.sort((a, b) {
      if (a.isUnlocked != b.isUnlocked) {
        return a.isUnlocked ? -1 : 1;
      }
      return b.rarity.index.compareTo(a.rarity.index);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredAchievements.length,
      itemBuilder: (context, index) {
        return _AchievementTile(achievement: filteredAchievements[index]);
      },
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;

  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppColors.cardBackground
            : AppColors.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: isUnlocked
            ? Border.all(color: achievement.rarity.color, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Achievement icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? achievement.rarity.color.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              achievement.icon,
              color: isUnlocked ? achievement.rarity.color : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Achievement details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.name,
                        style: TextStyle(
                          color: isUnlocked
                              ? AppColors.primaryText
                              : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: achievement.rarity.color.withOpacity(
                          isUnlocked ? 0.2 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        achievement.rarity.label,
                        style: TextStyle(
                          color: isUnlocked
                              ? achievement.rarity.color
                              : Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: isUnlocked
                        ? AppColors.secondaryText
                        : Colors.grey.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
                if (isUnlocked && achievement.unlockedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Lock/check icon
          Icon(
            isUnlocked ? Icons.check_circle : Icons.lock,
            color: isUnlocked ? AppColors.success : Colors.grey,
            size: 24,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
