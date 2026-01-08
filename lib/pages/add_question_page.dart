import 'package:flutter/material.dart';
import '../models/lib/models.dart';

class AddQuestionPage extends StatefulWidget {
  final Question? question;

  const AddQuestionPage({Key? key, this.question}) : super(key: key);

  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  QuestionType _selectedType = QuestionType.multipleChoice;
  Difficulty _selectedDifficulty = Difficulty.medium;
  String _content = '';
  List<String> _options = ['', '', '', ''];
  int _correctAnswerIndex = 0;
  bool _correctAnswer = true;
  List<String> _fillAnswers = [''];
  String _shortAnswer = '';
  String _explanation = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.question != null) {
      _selectedType = widget.question!.type;
      _selectedDifficulty = widget.question!.difficulty;
      _content = widget.question!.content;
      _explanation = widget.question!.explanation ?? '';

      switch (widget.question!.type) {
        case QuestionType.multipleChoice:
          final mcq = widget.question as MultipleChoiceQuestion;
          _options = List.from(mcq.options);
          _correctAnswerIndex = mcq.correctAnswerIndex;
          break;
        case QuestionType.trueFalse:
          final tfq = widget.question as TrueFalseQuestion;
          _correctAnswer = tfq.correctAnswer;
          break;
        case QuestionType.fillInTheBlank:
          final fibq = widget.question as FillInTheBlankQuestion;
          _fillAnswers = List.from(fibq.correctAnswers);
          break;
        case QuestionType.shortAnswer:
          final saq = widget.question as ShortAnswerQuestion;
          _shortAnswer = saq.referenceAnswer;
          break;
      }
    }
  }

  void _addOption() {
    setState(() {
      _options.add('');
    });
  }

  void _removeOption(int index) {
    if (_options.length > 2) {
      setState(() {
        _options.removeAt(index);
        if (_correctAnswerIndex >= _options.length) {
          _correctAnswerIndex = _options.length - 1;
        }
      });
    }
  }

  void _addBlank() {
    setState(() {
      _fillAnswers.add('');
    });
  }

  void _removeBlank(int index) {
    if (_fillAnswers.length > 1) {
      setState(() {
        _fillAnswers.removeAt(index);
      });
    }
  }

  Question _createQuestion() {
    final id = widget.question?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    switch (_selectedType) {
      case QuestionType.multipleChoice:
        return MultipleChoiceQuestion(
          id: id,
          content: _content,
          difficulty: _selectedDifficulty,
          options: _options,
          correctAnswerIndex: _correctAnswerIndex,
          explanation: _explanation.isEmpty ? null : _explanation,
          createdAt: widget.question?.createdAt ?? now,
          updatedAt: now,
        );
      case QuestionType.trueFalse:
        return TrueFalseQuestion(
          id: id,
          content: _content,
          difficulty: _selectedDifficulty,
          correctAnswer: _correctAnswer,
          explanation: _explanation.isEmpty ? null : _explanation,
          createdAt: widget.question?.createdAt ?? now,
          updatedAt: now,
        );
      case QuestionType.fillInTheBlank:
        return FillInTheBlankQuestion(
          id: id,
          content: _content,
          difficulty: _selectedDifficulty,
          correctAnswers: _fillAnswers,
          explanation: _explanation.isEmpty ? null : _explanation,
          createdAt: widget.question?.createdAt ?? now,
          updatedAt: now,
        );
      case QuestionType.shortAnswer:
        return ShortAnswerQuestion(
          id: id,
          content: _content,
          difficulty: _selectedDifficulty,
          referenceAnswer: _shortAnswer,
          explanation: _explanation.isEmpty ? null : _explanation,
          createdAt: widget.question?.createdAt ?? now,
          updatedAt: now,
        );
    }
  }

  String _getQuestionTypeText(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return '选择题';
      case QuestionType.trueFalse:
        return '判断题';
      case QuestionType.fillInTheBlank:
        return '填空题';
      case QuestionType.shortAnswer:
        return '简答题';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.question != null ? '编辑题目' : '添加题目'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 题目类型选择
              DropdownButtonFormField<QuestionType>(
                decoration: const InputDecoration(
                  labelText: '题目类型',
                  border: OutlineInputBorder(),
                ),
                value: _selectedType,
                items: QuestionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getQuestionTypeText(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                validator: (value) => value == null ? '请选择题目类型' : null,
              ),
              const SizedBox(height: 16),
              // 题目难度选择
              DropdownButtonFormField<Difficulty>(
                decoration: const InputDecoration(
                  labelText: '题目难度',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDifficulty,
                items: Difficulty.values.map((difficulty) {
                  return DropdownMenuItem(
                    value: difficulty,
                    child: Text(
                      difficulty == Difficulty.easy
                          ? '简单'
                          : difficulty == Difficulty.medium
                              ? '中等'
                              : '困难',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value!;
                  });
                },
                validator: (value) => value == null ? '请选择题目难度' : null,
              ),
              const SizedBox(height: 16),
              // 题目内容
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '题目内容',
                  border: OutlineInputBorder(),
                  hintText: '请输入题目内容',
                ),
                maxLines: 3,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                initialValue: _content,
                onSaved: (value) => _content = value!,
                validator: (value) => value?.isEmpty ?? true ? '请输入题目内容' : null,
              ),
              const SizedBox(height: 16),
              // 不同类型题目的特定字段
              if (_selectedType == QuestionType.multipleChoice) ...[
                const Text('选项', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: '选项 ${String.fromCharCode(65 + index)}',
                            border: const OutlineInputBorder(),
                          ),
                          initialValue: value,
                          onSaved: (newValue) => _options[index] = newValue!,
                          validator: (value) => value?.isEmpty ?? true ? '请输入选项内容' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Radio<int>(
                        value: index,
                        groupValue: _correctAnswerIndex,
                        onChanged: (value) {
                          setState(() {
                            _correctAnswerIndex = value!;
                          });
                        },
                      ),
                      Text('正确'),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: '删除选项',
                        disabledColor: Colors.grey,
                        onPressed: _options.length > 2 ? () => _removeOption(index) : null,
                      ),
                    ],
                  );
                }).toList(),
                TextButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add),
                  label: const Text('添加选项'),
                ),
              ] else if (_selectedType == QuestionType.trueFalse) ...[
                const Text('正确答案', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _correctAnswer,
                      onChanged: (value) {
                        setState(() {
                          _correctAnswer = value!;
                        });
                      },
                    ),
                    const Text('对'),
                    const SizedBox(width: 16),
                    Radio<bool>(
                      value: false,
                      groupValue: _correctAnswer,
                      onChanged: (value) {
                        setState(() {
                          _correctAnswer = value!;
                        });
                      },
                    ),
                    const Text('错'),
                  ],
                ),
              ] else if (_selectedType == QuestionType.fillInTheBlank) ...[
                const Text('正确答案', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._fillAnswers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: '第 ${index + 1} 个空的答案',
                            border: const OutlineInputBorder(),
                          ),
                          initialValue: value,
                          onSaved: (newValue) => _fillAnswers[index] = newValue!,
                          validator: (value) => value?.isEmpty ?? true ? '请输入答案' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: '删除空',
                        disabledColor: Colors.grey,
                        onPressed: _fillAnswers.length > 1 ? () => _removeBlank(index) : null,
                      ),
                    ],
                  );
                }).toList(),
                TextButton.icon(
                  onPressed: _addBlank,
                  icon: const Icon(Icons.add),
                  label: const Text('添加空'),
                ),
              ] else if (_selectedType == QuestionType.shortAnswer) ...[
                const Text('参考答案', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '参考答案',
                    border: const OutlineInputBorder(),
                    hintText: '请输入参考答案',
                  ),
                  maxLines: 5,
                  minLines: 3,
                  keyboardType: TextInputType.multiline,
                  initialValue: _shortAnswer,
                  onSaved: (value) => _shortAnswer = value!,
                  validator: (value) => value?.isEmpty ?? true ? '请输入参考答案' : null,
                ),
              ],
              // 解析
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '解析（可选）',
                  border: OutlineInputBorder(),
                  hintText: '请输入解析（可选）',
                ),
                maxLines: 3,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                initialValue: _explanation,
                onSaved: (value) => _explanation = value!,
              ),
              const SizedBox(height: 32),
              // 提交按钮
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    final question = _createQuestion();
                    Navigator.pop(context, question);
                  }
                },
                icon: const Icon(Icons.save),
                label: Text(widget.question != null ? '保存修改' : '添加题目'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}