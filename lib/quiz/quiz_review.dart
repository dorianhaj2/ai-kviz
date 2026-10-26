import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/quiz_provider.dart';

class QuizReview extends StatelessWidget {
  const QuizReview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final questions = quizProvider.questions;
    final answeredQuestions = quizProvider.answeredQuestions;
    final selectedAnswers = quizProvider.selectedAnswers;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('Review Answers'),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.primaryText,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final wasAnswered = answeredQuestions.containsKey(index);
          final wasCorrect = answeredQuestions[index] ?? false;
          final selectedAnswer = selectedAnswers[index];

          return Card(
            color: AppColors.cardBackground,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: wasAnswered
                    ? (wasCorrect ? Colors.green : Colors.red)
                    : AppColors.secondaryText.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question header with number and status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: wasAnswered
                              ? (wasCorrect
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2))
                              : AppColors.secondaryText.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Question ${index + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: wasAnswered
                                ? (wasCorrect ? Colors.green : Colors.red)
                                : AppColors.secondaryText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (wasAnswered)
                        Icon(
                          wasCorrect ? Icons.check_circle : Icons.cancel,
                          color: wasCorrect ? Colors.green : Colors.red,
                          size: 24,
                        ),
                      if (!wasAnswered)
                        const Icon(
                          Icons.help_outline,
                          color: AppColors.secondaryText,
                          size: 24,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Question text
                  Text(
                    question.text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Answers
                  ...question.answers.entries.map((entry) {
                    final answerText = entry.key;
                    final isCorrect = entry.value;
                    final isSelected = selectedAnswer == answerText;

                    Color backgroundColor = AppColors.primaryBackground;
                    Color borderColor = AppColors.secondaryText.withOpacity(
                      0.3,
                    );
                    IconData? icon;
                    Color? iconColor;

                    if (isSelected && wasAnswered) {
                      // This was the selected answer
                      backgroundColor = isCorrect
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2);
                      borderColor = isCorrect ? Colors.green : Colors.red;
                      icon = isCorrect ? Icons.check : Icons.close;
                      iconColor = isCorrect ? Colors.green : Colors.red;
                    } else if (isCorrect && wasAnswered && !wasCorrect) {
                      // Show the correct answer when user got it wrong
                      backgroundColor = Colors.green.withOpacity(0.1);
                      borderColor = Colors.green;
                      icon = Icons.check;
                      iconColor = Colors.green;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          if (icon != null)
                            Icon(icon, color: iconColor, size: 20),
                          if (icon != null) const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              answerText,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.primaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Show "Not Answered" message if question wasn't answered
                  if (!wasAnswered)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryText.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.secondaryText,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Not answered',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
