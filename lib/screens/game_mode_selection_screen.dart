import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/game_mode.dart';
import '../widgets/topic_picker_screen.dart';

/// Screen for selecting game mode
class GameModeSelectionScreen extends StatelessWidget {
  const GameModeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('Select Game Mode'),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.primaryText,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Choose Your Challenge',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Each mode offers a unique quiz experience',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  children: GameMode.values.map((mode) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _GameModeCard(
                        mode: mode,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TopicPickerScreen(
                                gameMode: mode,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card widget for displaying a game mode option
class _GameModeCard extends StatelessWidget {
  final GameMode mode;
  final VoidCallback onTap;

  const _GameModeCard({
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: mode.color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: mode.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                mode.icon,
                color: mode.color,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.name,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    mode.description,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: mode.color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
