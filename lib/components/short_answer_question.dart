import 'package:flutter/material.dart';
import '../models/lib/models.dart';

class ShortAnswerQuestionWidget extends StatelessWidget {
  final ShortAnswerQuestion question;
  final String userAnswer;
  final ValueChanged<String>? onAnswerChanged;
  final bool showCorrectAnswer;
  final bool isAnswered;

  const ShortAnswerQuestionWidget({
    Key? key,
    required this.question,
    required this.userAnswer,
    this.onAnswerChanged,
    this.showCorrectAnswer = false,
    this.isAnswered = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.content,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 16),
        TextField(
          enabled: !isAnswered,
          controller: TextEditingController(text: userAnswer)
            ..addListener(() {
              onAnswerChanged?.call(TextEditingController().text);
            }),
          decoration: InputDecoration(
            hintText: '请输入您的答案',
            border: const OutlineInputBorder(),
            filled: isAnswered,
            fillColor: isAnswered ? Colors.grey[100] : null,
          ),
          maxLines: 5,
          minLines: 3,
          keyboardType: TextInputType.multiline,
          onChanged: onAnswerChanged,
        ),
        if (showCorrectAnswer && isAnswered) ...[
          const SizedBox(height: 16),
          Text(
            '参考答案:',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Text(
              question.referenceAnswer,
              style: const TextStyle(
                color: Colors.green,
              ),
            ),
          ),
          if (question.explanation != null) ...[
            const SizedBox(height: 8),
            Text(
              '解析: ${question.explanation}',
              style: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ],
    );
  }
}