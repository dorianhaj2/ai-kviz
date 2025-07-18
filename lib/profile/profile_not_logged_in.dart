import 'package:flutter/material.dart';
import '../constants.dart';
import '../account/login.dart';

class ProfileNotLoggedInScreen extends StatefulWidget {
  const ProfileNotLoggedInScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProfileNotLoggedInScreenState();
  }
}

class _ProfileNotLoggedInScreenState extends State<ProfileNotLoggedInScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              username,
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your profile',
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

            Container(
              padding: const EdgeInsets.all(24.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
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
