import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/achievement_service.dart';
import '../service_locator.dart';
import '../models/user_model.dart' as models;
import '../models/achievement_model.dart';
import '../providers/user_provider.dart';
import '../account/login.dart';
import 'edit_username.dart';
import 'achievements.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryButton,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: AppColors.primaryText),
            ),
          );
        }

        final isLoggedIn = snapshot.hasData && snapshot.data != null;

        if (isLoggedIn) {
          return _UserProfileContent(email: snapshot.data!.email!);
        }

        return const _GuestProfileContent();
      },
    );
  }
}

/// Profile content for logged in users
class _UserProfileContent extends StatelessWidget {
  final String email;

  const _UserProfileContent({required this.email});

  @override
  Widget build(BuildContext context) {
    final databaseService = getIt<DatabaseService>();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return FutureBuilder(
      future: databaseService.read(path: AppConstants.userDataCollection),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryButton,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading profile: ${snapshot.error}',
              style: const TextStyle(color: AppColors.primaryText),
            ),
          );
        }

        // Load user data into provider
        if (snapshot.hasData && snapshot.data != null) {
          final userDocs = snapshot.data!.docs
              .where((doc) => doc['email'] == email)
              .toList();

          if (userDocs.isNotEmpty) {
            final userDoc = userDocs.first;
            final user = models.User.fromFirestore(
              userDoc.id,
              userDoc.data() as Map<String, dynamic>,
            );

            WidgetsBinding.instance.addPostFrameCallback((_) {
              userProvider.setUser(user);
            });
          }
        }

        return const _ProfileContent(isLoggedIn: true);
      },
    );
  }
}

/// Profile content for guest users
class _GuestProfileContent extends StatelessWidget {
  const _GuestProfileContent();

  @override
  Widget build(BuildContext context) {
    return const _ProfileContent(isLoggedIn: false);
  }
}

/// Main profile content layout
class _ProfileContent extends StatelessWidget {
  final bool isLoggedIn;

  const _ProfileContent({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              userProvider.username,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your profile',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),

            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.school,
                    value: '${userProvider.quizzesCompleted}',
                    label: 'Quizzes Completed\n',
                    iconColor: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.emoji_events,
                    value: '${(userProvider.averageScore * 100).toStringAsFixed(1)}%',
                    label: 'Average Score\n',
                    iconColor: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rating and Achievements Row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.star,
                    value: '${userProvider.rating}',
                    label: 'Rating\n',
                    iconColor: Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _AchievementPreviewCard(
                    userId: userProvider.userId,
                    isLoggedIn: isLoggedIn,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Action buttons
            _ActionButtons(isLoggedIn: isLoggedIn),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// Statistics card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Achievement preview card for profile
class _AchievementPreviewCard extends StatefulWidget {
  final String userId;
  final bool isLoggedIn;

  const _AchievementPreviewCard({
    required this.userId,
    required this.isLoggedIn,
  });

  @override
  State<_AchievementPreviewCard> createState() => _AchievementPreviewCardState();
}

class _AchievementPreviewCardState extends State<_AchievementPreviewCard> {
  int _unlockedCount = 0;
  int _totalCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievementCount();
  }

  Future<void> _loadAchievementCount() async {
    if (!widget.isLoggedIn || widget.userId.isEmpty) {
      setState(() {
        _totalCount = 20; // Total achievements available
        _isLoading = false;
      });
      return;
    }

    try {
      final achievementService = getIt<AchievementService>();
      final stats = await achievementService.getAchievementStats(widget.userId);
      setState(() {
        _unlockedCount = stats['unlocked'] as int;
        _totalCount = stats['total'] as int;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AchievementsScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.military_tech,
              color: Colors.amber,
              size: 32,
            ),
            const SizedBox(height: 8),
            _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryButton,
                    ),
                  )
                : Text(
                    '$_unlockedCount / $_totalCount',
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const Text(
              'Achievements\n',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Action buttons container
class _ActionButtons extends StatelessWidget {
  final bool isLoggedIn;

  const _ActionButtons({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          if (isLoggedIn) ...[
            _ProfileButton(
              label: 'Edit Username',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditUsernameScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _ProfileButton(
              label: 'Log Out',
              textColor: Colors.red,
              onPressed: () {
                final authService = getIt<AuthService>();
                final userProvider = Provider.of<UserProvider>(
                  context,
                  listen: false,
                );
                authService.signOut();
                userProvider.logout();
              },
            ),
          ] else ...[
            _ProfileButton(
              icon: Icons.login,
              label: 'Log In',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Reusable profile button
class _ProfileButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color textColor;
  final VoidCallback onPressed;

  const _ProfileButton({
    this.icon,
    required this.label,
    this.textColor = AppColors.secondaryText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.buttonBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: OutlinedButton.icon(
        icon: icon != null
            ? Icon(icon, color: textColor)
            : const SizedBox.shrink(),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
          ),
        ),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.transparent),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
