import 'package:flutter/material.dart';
import '../models/lib/models.dart';
import 'add_question_page.dart';

class QuestionBankPage extends StatefulWidget {
  final QuizBank questionBank;
  final Function(Question) onQuestionAdded;
  final Function(String) onQuestionDeleted;
  final Function(Question) onQuestionUpdated;

  const QuestionBankPage({
    Key? key,
    required this.questionBank,
    required this.onQuestionAdded,
    required this.onQuestionDeleted,
    required this.onQuestionUpdated,
  }) : super(key: key);

  @override
  State<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  List<Question> _filteredQuestions = [];
  QuestionType? _selectedType;
  Difficulty? _selectedDifficulty;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredQuestions = widget.questionBank.getAllQuestions();
  }

  void _filterQuestions() {
    setState(() {
      _filteredQuestions = widget.questionBank.getAllQuestions().where((
        question,
      ) {
        final matchesType =
            _selectedType == null || question.type == _selectedType;
        final matchesDifficulty =
            _selectedDifficulty == null ||
            question.difficulty == _selectedDifficulty;
        final matchesSearch =
            _searchQuery.isEmpty ||
            question.content.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesType && matchesDifficulty && matchesSearch;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _selectedDifficulty = null;
      _searchQuery = '';
      _filteredQuestions = widget.questionBank.getAllQuestions();
    });
  }

  void _navigateToAddQuestion() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddQuestionPage()),
    );

    if (result is Question) {
      widget.onQuestionAdded(result);
      _filterQuestions();
    }
  }

  void _navigateToEditQuestion(Question question) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionPage(question: question),
      ),
    );

    if (result is Question) {
      widget.onQuestionUpdated(result);
      _filterQuestions();
    }
  }

  void _deleteQuestion(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这道题目吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              widget.onQuestionDeleted(id);
              _filterQuestions();
              Navigator.pop(context);
            },
            child: const Text('删除'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
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

  // 生成AI解析
  void _generateAIAnalysis(Question question) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('AI解析'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('正在生成AI解析，请稍候...'),
            ],
          ),
        );
      },
    );

    // 模拟API调用延迟
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);

      // 显示AI解析结果
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('AI解析结果'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    question.content,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue.withOpacity(0.05),
                    ),
                    child: Text(
                      '这道题主要考察了相关知识点的理解和应用。\n\n' +
                          '**核心知识点：**\n' +
                          '- 知识点1：相关概念和定义\n' +
                          '- 知识点2：实际应用场景\n' +
                          '- 知识点3：常见误区分析\n\n' +
                          '**解析过程：**\n' +
                          '1. 首先，我们需要理解题目所涉及的基本概念\n' +
                          '2. 然后，分析每个选项的正确性\n' +
                          '3. 最后，结合知识点得出正确答案\n\n' +
                          '**总结：**\n' +
                          '通过这道题，我们可以更好地理解相关知识点的实际应用，' +
                          '同时也能提高我们的分析和解决问题的能力。',
                      style: const TextStyle(fontSize: 14, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('关闭'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _generateAIAnalysis(question); // 重新生成解析
                },
                child: const Text('重新生成'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // 保存解析结果
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('解析结果已保存')));
                },
                child: const Text('保存解析'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('题库管理'),
        actions: [
          IconButton(
            onPressed: _navigateToAddQuestion,
            icon: const Icon(Icons.add),
            tooltip: '添加题目',
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选和搜索栏
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: '搜索题目',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                          _filterQuestions();
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _filterQuestions();
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<QuestionType>(
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
                              _selectedType = value;
                            });
                            _filterQuestions();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<Difficulty>(
                          decoration: const InputDecoration(
                            labelText: '难度',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedDifficulty,
                          items: Difficulty.values.map((difficulty) {
                            return DropdownMenuItem(
                              value: difficulty,
                              child: Text(_getDifficultyText(difficulty)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDifficulty = value;
                            });
                            _filterQuestions();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetFilters,
                      child: const Text('重置筛选'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 题目数量统计
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '共 ${_filteredQuestions.length} 道题目',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          // 题目列表
          Expanded(
            child: _filteredQuestions.isEmpty
                ? const Center(child: Text('没有找到题目'))
                : ListView.builder(
                    itemCount: _filteredQuestions.length,
                    itemBuilder: (context, index) {
                      final question = _filteredQuestions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _getQuestionTypeText(question.type),
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color:
                                          question.difficulty == Difficulty.easy
                                          ? Colors.green
                                          : question.difficulty ==
                                                Difficulty.medium
                                          ? Colors.orange
                                          : Colors.red,
                                    ),
                                    child: Text(
                                      _getDifficultyText(question.difficulty),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                question.content,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _generateAIAnalysis(question),
                                    icon: Icon(
                                      Icons.lightbulb_outline,
                                      color: Colors.yellow[600],
                                    ),
                                    tooltip: 'AI解析',
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _navigateToEditQuestion(question),
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    tooltip: '编辑',
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _deleteQuestion(question.id),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    tooltip: '删除',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
