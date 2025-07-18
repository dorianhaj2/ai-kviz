// file: quiz.dart

import 'package:aikviz/quiz/result.dart';
import 'package:flutter/material.dart';
import 'question.dart';
import 'answer.dart';
import '../constants.dart';
import '../services/database_service.dart';

class Quiz extends StatefulWidget {
  final Function(bool) answerQuestion;
  final Function() resetQuiz;

  const Quiz({Key? key, required this.answerQuestion, required this.resetQuiz})
    : super(key: key);

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  String? selectedAnswerIndex;
  bool answerClicked = false;

  void updateUserData() async {
    print(userId);
    await DatabaseService().update(
      path: "UserData",
      id: userId,
      data: {
        'quizzes': quizzesCompleted,
        'avg_score': averageScore,
        'total_correct': totalCorrect,
        'total_answers': totalAnswers,
      },
    );
  }

  void handleAnswer(bool isCorrect, String index) {
    if (answerClicked) return; // Prevent multiple clicks
    setState(() {
      selectedAnswerIndex = index;
      answerClicked = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      widget.answerQuestion(isCorrect);
      setState(() {
        selectedAnswerIndex = null;
        answerClicked = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get results if the quiz is completed
    if (questionIndex >= questions.length) {
      quizzesCompleted++;
      totalAnswers += questions.length;
      totalCorrect += totalScore;
      averageScore = totalCorrect / totalAnswers;

      if (userId != '' && userId.isNotEmpty) {
        updateUserData();
      }
      return Result(totalScore, questions.length, widget.resetQuiz);
    }
    final Map<String, bool> answers =
        questions[questionIndex]['answers'] as Map<String, bool>;

    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        title: Text("Question  ${questionIndex + 1}/${questions.length}"),
        backgroundColor: cardBackgroundColor,
        foregroundColor: primaryTextColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Question(questions[questionIndex]['questionText'] as String),

            const SizedBox(height: 20),

            ...answers.entries.map<Widget>((entry) {
              final String idx = entry.key;
              final String answerText = entry.key;
              final bool isCorrect = entry.value;

              return Answer(
                () => handleAnswer(isCorrect, idx),
                answerText,
                isSelected: selectedAnswerIndex == idx,
                isCorrectAnswer: isCorrect,
                isDisabled: answerClicked,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
