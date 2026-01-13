import 'package:flutter/material.dart';
import '../models/lib/models.dart';
import 'quiz_page.dart';
import 'question_bank_page.dart';

class BankDetailPage extends StatelessWidget {
  final QuizBank bank;
  final Function(Question) onQuestionAdded;
  final Function(String) onQuestionDeleted;
  final Function(Question) onQuestionUpdated;

  const BankDetailPage({
    Key? key,
    required this.bank,
    required this.onQuestionAdded,
    required this.onQuestionDeleted,
    required this.onQuestionUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final questions = bank.getAllQuestions();
    final totalQuestions = questions.length;
    final easyQuestions = questions
        .where((q) => q.difficulty == Difficulty.easy)
        .length;
    final mediumQuestions = questions
        .where((q) => q.difficulty == Difficulty.medium)
        .length;
    final hardQuestions = questions
        .where((q) => q.difficulty == Difficulty.hard)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(bank.name),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionBankPage(
                    questionBank: bank,
                    onQuestionAdded: onQuestionAdded,
                    onQuestionDeleted: onQuestionDeleted,
                    onQuestionUpdated: onQuestionUpdated,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit),
            tooltip: '编辑题库',
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 题库信息卡片
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bank.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bank.description ?? '暂无描述',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // 统计信息
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('总题数', totalQuestions.toString()),
                            _buildStatItem('简单', easyQuestions.toString()),
                            _buildStatItem('中等', mediumQuestions.toString()),
                            _buildStatItem('困难', hardQuestions.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 练习模式选择
                const Text(
                  '练习模式',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // 练习模式卡片
                Column(
                  children: [
                    _buildPracticeModeCard(
                      context,
                      title: '顺序练习',
                      description: '按照题目顺序依次练习',
                      icon: Icons.play_arrow,
                      onTap: () {
                        if (totalQuestions > 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizPage(
                                questions: questions,
                                title: '顺序练习 - ${bank.name}',
                              ),
                            ),
                          );
                        } else {
                          _showMessage(context, '该题库为空，请先添加题目');
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPracticeModeCard(
                      context,
                      title: '随机练习',
                      description: '随机抽取题目进行练习',
                      icon: Icons.shuffle,
                      onTap: () {
                        if (totalQuestions > 0) {
                          final shuffledQuestions = [...questions]..shuffle();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizPage(
                                questions: shuffledQuestions,
                                title: '随机练习 - ${bank.name}',
                              ),
                            ),
                          );
                        } else {
                          _showMessage(context, '该题库为空，请先添加题目');
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPracticeModeCard(
                      context,
                      title: '专项练习',
                      description: '选择特定难度或类型进行练习',
                      icon: Icons.filter_list,
                      onTap: () {
                        if (totalQuestions > 0) {
                          _showFilterDialog(context, questions, bank.name);
                        } else {
                          _showMessage(context, '该题库为空，请先添加题目');
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildPracticeModeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(icon, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    List<Question> questions,
    String bankName,
  ) {
    Difficulty? selectedDifficulty;
    QuestionType? selectedType;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('专项练习设置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Difficulty>(
                decoration: const InputDecoration(
                  labelText: '难度',
                  border: OutlineInputBorder(),
                ),
                value: selectedDifficulty,
                items: [
                  const DropdownMenuItem(value: null, child: Text('全部')),
                  ...Difficulty.values.map((difficulty) {
                    return DropdownMenuItem(
                      value: difficulty,
                      child: Text(_getDifficultyText(difficulty)),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  selectedDifficulty = value;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<QuestionType>(
                decoration: const InputDecoration(
                  labelText: '题目类型',
                  border: OutlineInputBorder(),
                ),
                value: selectedType,
                items: [
                  const DropdownMenuItem(value: null, child: Text('全部')),
                  ...QuestionType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getQuestionTypeText(type)),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  selectedType = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                final filteredQuestions = questions.where((q) {
                  final matchesDifficulty =
                      selectedDifficulty == null ||
                      q.difficulty == selectedDifficulty;
                  final matchesType =
                      selectedType == null || q.type == selectedType;
                  return matchesDifficulty && matchesType;
                }).toList();

                if (filteredQuestions.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPage(
                        questions: filteredQuestions,
                        title: '专项练习 - ${bankName}',
                      ),
                    ),
                  );
                } else {
                  _showMessage(context, '没有符合条件的题目');
                }
              },
              child: const Text('开始练习'),
            ),
          ],
        );
      },
    );
  }

  String _getDifficultyText(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '简单';
      case Difficulty.medium:
        return '中等';
      case Difficulty.hard:
        return '困难';
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

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
