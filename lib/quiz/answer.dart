// file: answer.dart

import 'package:flutter/material.dart';

class Answer extends StatefulWidget {
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
  State<Answer> createState() => _AnswerState();
}

class _AnswerState extends State<Answer> {
  @override
  Widget build(BuildContext context) {
    // Use the widget properties to determine the button's appearance and behavior
    Color backgroundColor = Color(0xff271845);
    if (widget.isSelected) {
      if (widget.isCorrectAnswer) {
        backgroundColor = Colors.green;
      } else {
        backgroundColor = Colors.red;
      }
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
        onPressed: widget.isDisabled ? null : widget.selectHandler,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        ),
        child: Text(
          widget.answerText,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
