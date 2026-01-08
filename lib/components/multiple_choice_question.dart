import 'package:flutter/material.dart';
import '../models/lib/models.dart';

class MultipleChoiceQuestionWidget extends StatelessWidget {
  final MultipleChoiceQuestion question;
  final int? selectedAnswerIndex;
  final ValueChanged<int>? onAnswerSelected;
  final bool showCorrectAnswer;
  final bool isAnswered;

  const MultipleChoiceQuestionWidget({
    Key? key,
    required this.question,
    this.selectedAnswerIndex,
    this.onAnswerSelected,
    this.showCorrectAnswer = false,
    this.isAnswered = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: question.options.length,
          itemBuilder: (context, index) {
            final isSelected = selectedAnswerIndex == index;
            final isCorrect = index == question.correctAnswerIndex;
            final showFeedback = isAnswered && (isSelected || isCorrect);

            Color? optionColor;
            IconData? optionIcon;

            if (showFeedback) {
              if (isSelected && isCorrect) {
                optionColor = Colors.green;
                optionIcon = Icons.check_circle;
              } else if (isSelected && !isCorrect) {
                optionColor = Colors.red;
                optionIcon = Icons.close;
              } else if (isCorrect) {
                optionColor = Colors.green;
                optionIcon = Icons.check_circle;
              }
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: showFeedback 
                    ? optionColor?.withOpacity(0.1) 
                    : isSelected 
                        ? Colors.blue.withOpacity(0.1) 
                        : Colors.white,
                border: Border.all(
                  color: showFeedback 
                      ? optionColor ?? Colors.transparent
                      : isSelected 
                          ? Colors.blue
                          : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: !isAnswered ? () => onAnswerSelected?.call(index) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: showFeedback 
                                  ? optionColor ?? Colors.grey[400]!
                                  : isSelected 
                                      ? Colors.blue
                                      : Colors.grey[400]!,
                              width: 2,
                            ),
                            color: showFeedback && isCorrect ? Colors.green : Colors.transparent,
                          ),
                          child: showFeedback && isCorrect
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                    color: showFeedback 
                                        ? optionColor ?? Colors.grey[600]
                                        : isSelected 
                                            ? Colors.blue
                                            : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            question.options[index],
                            style: TextStyle(
                              fontSize: 16,
                              color: showFeedback && isSelected
                                  ? optionColor
                                  : Colors.black,
                            ),
                          ),
                        ),
                        if (showFeedback && isSelected)
                          Icon(
                            optionIcon,
                            color: optionColor,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}