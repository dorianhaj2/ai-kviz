import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../service_locator.dart';
import '../models/user_model.dart' as models;
import '../providers/user_provider.dart';
import '../screens/game_mode_selection_screen.dart';
import '../account/login.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
          return _UserHomeContent(email: snapshot.data!.email!);
        }
        
        return const _GuestHomeContent();
      },
    );
  }
}

/// Home content for logged in users
class _UserHomeContent extends StatelessWidget {
  final String email;
  
  const _UserHomeContent({required this.email});

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
              'Error loading user data: ${snapshot.error}',
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
            final user = models.User.fromFirestore(userDoc.id, userDoc.data() as Map<String, dynamic>);
            
            // Update provider if user data has changed
            WidgetsBinding.instance.addPostFrameCallback((_) {
              userProvider.setUser(user);
            });
          }
        }
        
        return const _HomeContent(isLoggedIn: true);
      },
    );
  }
}

/// Home content for guest users
class _GuestHomeContent extends StatelessWidget {
  const _GuestHomeContent();

  @override
  Widget build(BuildContext context) {
    return const _HomeContent(isLoggedIn: false);
  }
}

/// Main home content layout
class _HomeContent extends StatelessWidget {
  final bool isLoggedIn;
  
  const _HomeContent({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'QuizMaster',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test your knowledge and challenge yourself',
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
            const SizedBox(height: 30),
            
            // Action Card
            _ActionCard(isLoggedIn: isLoggedIn),
            
            const Spacer(),
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

/// Action card with buttons
class _ActionCard extends StatelessWidget {
  final bool isLoggedIn;
  
  const _ActionCard({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ready to Play?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose an option below to get started',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow, color: AppColors.primaryText),
            label: const Text(
              'Start Quiz',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 16,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GameModeSelectionScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryButton,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
          if (!isLoggedIn) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.buttonBackground,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.login, color: AppColors.secondaryText),
                label: const Text(
                  'Log In',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.transparent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
