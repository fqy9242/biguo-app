import 'package:flutter/material.dart';
import '../models/lib/models.dart';
import './multiple_choice_question.dart';
import './true_false_question.dart';
import './fill_in_the_blank_question.dart';
import './short_answer_question.dart';

class QuestionWidget extends StatelessWidget {
  final Question question;
  final dynamic userAnswer;
  final ValueChanged<dynamic>? onAnswerChanged;
  final bool showCorrectAnswer;
  final bool isAnswered;

  const QuestionWidget({
    Key? key,
    required this.question,
    required this.userAnswer,
    this.onAnswerChanged,
    this.showCorrectAnswer = false,
    this.isAnswered = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return MultipleChoiceQuestionWidget(
          question: question as MultipleChoiceQuestion,
          selectedAnswerIndex: userAnswer as int?,
          onAnswerSelected: onAnswerChanged as ValueChanged<int>?,
          showCorrectAnswer: showCorrectAnswer,
          isAnswered: isAnswered,
        );
      case QuestionType.trueFalse:
        return TrueFalseQuestionWidget(
          question: question as TrueFalseQuestion,
          selectedAnswer: userAnswer as bool?,
          onAnswerSelected: onAnswerChanged as ValueChanged<bool>?,
          showCorrectAnswer: showCorrectAnswer,
          isAnswered: isAnswered,
        );
      case QuestionType.fillInTheBlank:
        return FillInTheBlankQuestionWidget(
          question: question as FillInTheBlankQuestion,
          userAnswers: userAnswer as List<String>,
          onAnswerChanged: onAnswerChanged as ValueChanged<List<String>>?,
          showCorrectAnswer: showCorrectAnswer,
          isAnswered: isAnswered,
        );
      case QuestionType.shortAnswer:
        return ShortAnswerQuestionWidget(
          question: question as ShortAnswerQuestion,
          userAnswer: userAnswer as String,
          onAnswerChanged: onAnswerChanged as ValueChanged<String>?,
          showCorrectAnswer: showCorrectAnswer,
          isAnswered: isAnswered,
        );
      default:
        return const Text('不支持的题目类型');
    }
  }
}