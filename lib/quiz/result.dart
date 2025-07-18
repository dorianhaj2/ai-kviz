import 'package:flutter/material.dart';
import 'package:aikviz/constants.dart';

class Result extends StatelessWidget {
  final int resultScore;
  final int totalQuestions;
  final VoidCallback resetHandler;

  const Result(
    this.resultScore,
    this.totalQuestions,
    this.resetHandler, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double percentageScore = totalQuestions > 0
        ? resultScore / totalQuestions
        : 0.0;

    return Scaffold(
      backgroundColor: primaryBackgroundColor,
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
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),

            // This Stack allows us to place the score text on top of the progress circle.
            Stack(
              alignment: Alignment.center,
              children: [
                // The circular progress indicator
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: percentageScore,
                    strokeWidth: 12,
                    backgroundColor: const Color(0xff271845), // The track color
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xff6a2ae5),
                    ), // The progress color
                  ),
                ),
                // The text showing the score (e.g., "4 / 5")
                Text(
                  '$resultScore / $totalQuestions',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text(
              'You have successfully completed the quiz.',
              style: TextStyle(fontSize: 16, color: Color(0xffc4b5fd)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // The button to restart the quiz
            ElevatedButton(
              onPressed: () {
                resetHandler();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xff6a2ae5,
                ), // Primary button color
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
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
