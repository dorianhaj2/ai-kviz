import 'package:flutter/material.dart';
import '../constants.dart';
import '../quiz/quiz.dart';

class HomeLoggedInScreen extends StatefulWidget {
  final Function(bool) answerQuestion;
  final Function() resetQuiz;
  // final int quizzesCompletedLocal;
  // final double averageScoreLocal;

  HomeLoggedInScreen({
    Key? key,
    required this.answerQuestion,
    required this.resetQuiz,
    // required this.quizzesCompletedLocal,
    // required this.averageScoreLocal,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeLoggedInScreenState();
  }
}

class _HomeLoggedInScreenState extends State<HomeLoggedInScreen> {
  @override
  Widget build(BuildContext context) {
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
                color: primaryTextColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test your knowledge and challenge yourself',
              style: TextStyle(color: secondaryTextColor, fontSize: 16),
            ),
            const SizedBox(height: 30),
            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.school,
                    value: '$quizzesCompleted',
                    label: 'Quizzes Completed\n',
                    iconColor: secondaryTextColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    icon: Icons.emoji_events,
                    value: '${(averageScore * 100).toStringAsFixed(1)}%',
                    label: 'Average Score\n',
                    iconColor: secondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Action Card
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Ready to Play?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose an option below to get started',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryTextColor, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow, color: primaryTextColor),
                    label: const Text(
                      'Start Quiz',
                      style: TextStyle(color: primaryTextColor, fontSize: 16),
                    ),
                    onPressed: () async {
                      await initializeQuestions();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Quiz(
                              answerQuestion: widget.answerQuestion,
                              resetQuiz: widget.resetQuiz,
                            );
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryButtonColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // This will push all content up
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
