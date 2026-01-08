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
      _filteredQuestions = widget.questionBank.getAllQuestions().where((question) {
        final matchesType = _selectedType == null || question.type == _selectedType;
        final matchesDifficulty = _selectedDifficulty == null || question.difficulty == _selectedDifficulty;
        final matchesSearch = _searchQuery.isEmpty || 
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
      MaterialPageRoute(
        builder: (context) => const AddQuestionPage(),
      ),
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
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
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _getQuestionTypeText(question.type),
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: question.difficulty == Difficulty.easy
                                          ? Colors.green
                                          : question.difficulty == Difficulty.medium
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
                                    onPressed: () => _navigateToEditQuestion(question),
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    tooltip: '编辑',
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteQuestion(question.id),
                                    icon: const Icon(Icons.delete, color: Colors.red),
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