import 'package:flutter/material.dart';
import '../models/lib/models.dart';

class TrueFalseQuestionWidget extends StatelessWidget {
  final TrueFalseQuestion question;
  final bool? selectedAnswer;
  final ValueChanged<bool>? onAnswerSelected;
  final bool showCorrectAnswer;
  final bool isAnswered;

  const TrueFalseQuestionWidget({
    Key? key,
    required this.question,
    this.selectedAnswer,
    this.onAnswerSelected,
    this.showCorrectAnswer = false,
    this.isAnswered = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOptionButton(
              context,
              '对',
              true,
              selectedAnswer == true,
              question.correctAnswer == true,
            ),
            const SizedBox(width: 32),
            _buildOptionButton(
              context,
              '错',
              false,
              selectedAnswer == false,
              question.correctAnswer == false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    String text,
    bool value,
    bool isSelected,
    bool isCorrect,
  ) {
    final showFeedback = isAnswered && (isSelected || isCorrect);
    Color? buttonColor;
    IconData? buttonIcon;

    if (showFeedback) {
      if (isSelected && isCorrect) {
        buttonColor = Colors.green;
        buttonIcon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        buttonColor = Colors.red;
        buttonIcon = Icons.close;
      } else if (isCorrect) {
        buttonColor = Colors.green;
        buttonIcon = Icons.check_circle;
      }
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: showFeedback 
              ? buttonColor?.withOpacity(0.1) 
              : isSelected 
                  ? Colors.blue.withOpacity(0.1) 
                  : Colors.white,
          border: Border.all(
            color: showFeedback 
                ? buttonColor ?? Colors.transparent
                : isSelected 
                    ? Colors.blue
                    : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: !isAnswered ? () => onAnswerSelected?.call(value) : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showFeedback && isCorrect)
                    Icon(
                      buttonIcon,
                      color: buttonColor,
                      size: 20,
                    ),
                  if (showFeedback && isCorrect)
                    const SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: showFeedback 
                          ? buttonColor 
                          : isSelected 
                              ? Colors.blue 
                              : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}