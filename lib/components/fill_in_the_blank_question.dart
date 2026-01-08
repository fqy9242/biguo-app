import 'package:flutter/material.dart';
import '../models/lib/models.dart';

class FillInTheBlankQuestionWidget extends StatelessWidget {
  final FillInTheBlankQuestion question;
  final List<String> userAnswers;
  final ValueChanged<List<String>>? onAnswerChanged;
  final bool showCorrectAnswer;
  final bool isAnswered;

  const FillInTheBlankQuestionWidget({
    Key? key,
    required this.question,
    required this.userAnswers,
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
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: question.correctAnswers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text('${index + 1}. ', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      enabled: !isAnswered,
                      controller: TextEditingController(
                        text: userAnswers.length > index ? userAnswers[index] : '',
                      )..addListener(() {
                          final newAnswers = List<String>.from(userAnswers);
                          if (newAnswers.length <= index) {
                            newAnswers.addAll(List.filled(index - newAnswers.length + 1, ''));
                          }
                          newAnswers[index] = (newAnswers[index] = TextEditingController().text);
                          onAnswerChanged?.call(newAnswers);
                        }),
                      decoration: InputDecoration(
                        hintText: '请输入答案',
                        border: const OutlineInputBorder(),
                        filled: isAnswered,
                        fillColor: isAnswered ? Colors.grey[100] : null,
                      ),
                      onChanged: (value) {
                        final newAnswers = List<String>.from(userAnswers);
                        if (newAnswers.length <= index) {
                          newAnswers.addAll(List.filled(index - newAnswers.length + 1, ''));
                        }
                        newAnswers[index] = value;
                        onAnswerChanged?.call(newAnswers);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (showCorrectAnswer && isAnswered) ...[
          const SizedBox(height: 16),
          Text(
            '正确答案:',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          for (int i = 0; i < question.correctAnswers.length; i++)
            Text(
              '${i + 1}. ${question.correctAnswers[i]}',
              style: const TextStyle(
                color: Colors.green,
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