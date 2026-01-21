import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class Answer extends StatelessWidget {
  final VoidCallback selectHandler;
  final String answerText;
  final bool isSelected;
  final bool isCorrectAnswer;
  final bool isDisabled;

  const Answer(
    this.selectHandler,
    this.answerText, {
    Key? key,
    this.isSelected = false,
    this.isCorrectAnswer = false,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppColors.cardBackground;
    
    if (isSelected) {
      backgroundColor = isCorrectAnswer ? Colors.green : Colors.red;
    } else if (isDisabled && isCorrectAnswer) {
      backgroundColor = Colors.green;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xff4c1d95), width: 2.0),
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : selectHandler,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primaryText,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          answerText,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}
