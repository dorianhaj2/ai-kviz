import 'package:flutter/material.dart';
import '../constants.dart';
import '../quiz/quiz.dart';
import '../account/login.dart';

class HomeNotLoggedInScreen extends StatefulWidget {
  final Function(bool) answerQuestion;
  final Function() resetQuiz;

  HomeNotLoggedInScreen({
    Key? key,
    required this.answerQuestion,
    required this.resetQuiz,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeNotLoggedInScreenState();
  }
}

class _HomeNotLoggedInScreenState extends State<HomeNotLoggedInScreen> {
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
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: buttonBackgroundColor,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.login, color: secondaryTextColor),
                      label: const Text(
                        'Log In',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const LoginScreen();
                            },
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
