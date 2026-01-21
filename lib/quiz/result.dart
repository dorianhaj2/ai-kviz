import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/quiz_result.dart';
import '../models/achievement_model.dart';
import '../models/game_mode.dart';
import '../providers/quiz_provider.dart';
import '../providers/user_provider.dart';

class Result extends StatelessWidget {
  final QuizResult quizResult;
  final int? ratingChange;
  final List<Achievement> newAchievements;
  final GameMode? gameMode;
  final int? questionsAnswered;

  const Result({
    Key? key,
    required this.quizResult,
    this.ratingChange,
    this.newAchievements = const [],
    this.gameMode,
    this.questionsAnswered,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final totalQuestions = gameMode == GameMode.timed || gameMode == GameMode.survival ? questionsAnswered : quizResult.totalQuestions;
    final double percentageScore = totalQuestions != null && totalQuestions > 0
        ? quizResult.score / totalQuestions
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Quiz Completed!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 30),

            // Score circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: percentageScore,
                    strokeWidth: 12,
                    backgroundColor: AppColors.cardBackground,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryButton,
                    ),
                  ),
                ),
                Text(
                  '${quizResult.score} / $totalQuestions',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            
            const Text(
              'You have successfully completed the quiz.',
              style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),

            // Rating change display (only for logged in users)
            if (ratingChange != null && userProvider.isLoggedIn) ...[
              const SizedBox(height: 24),
              _buildRatingChangeWidget(ratingChange!, userProvider.rating),
            ],

            // New achievements display
            if (newAchievements.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildNewAchievementsWidget(),
            ],

            const SizedBox(height: 40),

            // Back to home button
            ElevatedButton(
              onPressed: () {
                final quizProvider = Provider.of<QuizProvider>(
                  context,
                  listen: false,
                );
                quizProvider.resetQuiz();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(color: AppColors.primaryText, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingChangeWidget(int change, int currentRating) {
    final bool isPositive = change > 0;
    final bool isNeutral = change == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNeutral
              ? AppColors.secondaryText.withOpacity(0.3)
              : (isPositive
                    ? Colors.green.withOpacity(0.5)
                    : Colors.red.withOpacity(0.5)),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isNeutral
                    ? Icons.remove
                    : (isPositive ? Icons.arrow_upward : Icons.arrow_downward),
                color: isNeutral
                    ? AppColors.secondaryText
                    : (isPositive ? Colors.green : Colors.red),
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                isNeutral ? '0' : '${isPositive ? '+' : ''}$change',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isNeutral
                      ? AppColors.secondaryText
                      : (isPositive ? Colors.green : Colors.red),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Rating',
                style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                'New Rating: $currentRating',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewAchievementsWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                'Achievement${newAchievements.length > 1 ? 's' : ''} Unlocked!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...newAchievements.map(
            (achievement) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: achievement.rarity.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      achievement.icon,
                      color: achievement.rarity.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                      Text(
                        achievement.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
