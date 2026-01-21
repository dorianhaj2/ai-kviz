import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../widgets/loading_screen.dart';
import '../quiz/quiz.dart';
import '../quiz/timed_quiz.dart';
import '../quiz/survival_quiz.dart';
import '../quiz/arcade_quiz.dart';
import '../providers/quiz_provider.dart';
import '../services/question_service.dart';
import '../service_locator.dart';
import '../models/game_mode.dart';

class DifficultyPickerScreen extends StatefulWidget {
  final String topic;
  final GameMode gameMode;

  const DifficultyPickerScreen({
    Key? key,
    required this.topic,
    this.gameMode = GameMode.normal,
  }) : super(key: key);

  @override
  State<DifficultyPickerScreen> createState() => _DifficultyPickerScreenState();
}

class _DifficultyPickerScreenState extends State<DifficultyPickerScreen> {
  bool _isLoading = false;

  final List<Map<String, dynamic>> difficulties = [
    {
      'name': 'Easy',
      'description': 'Simple questions for beginners',
    },
    {
      'name': 'Medium',
      'description': 'Moderate challenge',
    },
    {
      'name': 'Hard',
      'description': 'Difficult questions for experts',
    },
  ];

  Future<void> _onDifficultySelected(String difficulty) async {
    setState(() {
      _isLoading = true;
    });

    // Show loading screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoadingScreen(),
      ),
    );

    try {
      // Initialize questions using QuestionService with difficulty
      final questionService = getIt<QuestionService>();
      int count = 10;
      if (widget.gameMode == GameMode.timed || widget.gameMode == GameMode.survival) {
        count = 40; // More questions for timed mode
      }

      final questions = await questionService.initializeQuestions(
        widget.topic,
        difficulty: difficulty,
        count: count,
      );

      if (context.mounted) {
        // Update the quiz provider with questions
        final quizProvider = Provider.of<QuizProvider>(context, listen: false);
        quizProvider.initializeQuiz(
          questions,
          topic: widget.topic,
          difficulty: difficulty,
          gameMode: widget.gameMode,
        );

        // Navigate to appropriate quiz widget based on game mode
        Widget quizWidget;
        switch (widget.gameMode) {
          case GameMode.timed:
            quizWidget = const TimedQuiz();
            break;
          case GameMode.survival:
            quizWidget = const SurvivalQuiz();
            break;
          case GameMode.arcade:
            quizWidget = const ArcadeQuiz();
            break;
          case GameMode.normal:
          default:
            quizWidget = const Quiz();
            break;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => quizWidget,
          ),
        );
      }
    } catch (e) {
      // Handle error and go back
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load questions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text("Select Difficulty - ${widget.topic}"),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.primaryText,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose difficulty level',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Difficulty buttons
              ...difficulties.map<Widget>((diff) {
                return _DifficultyButton(
                  name: diff['name'],
                  description: diff['description'],
                  onPressed: () => _onDifficultySelected(diff['name']),
                  isLoading: _isLoading,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// Difficulty button widget
class _DifficultyButton extends StatelessWidget {
  final String name;
  final String description;
  final VoidCallback onPressed;
  final bool isLoading;

  const _DifficultyButton({
    required this.name,
    required this.description,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xff4c1d95), width: 2.0),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primaryText,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
