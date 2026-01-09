import 'package:flutter/material.dart';
import '../models/lib/models.dart';
import '../components/question_widget.dart';

class QuizPage extends StatefulWidget {
  final List<Question> questions;
  final String title;

  const QuizPage({
    Key? key,
    required this.questions,
    this.title = '开始练习',
  }) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  Map<String, dynamic> _userAnswers = {};
  Map<String, bool> _isCorrect = {};
  Set<String> _answeredQuestions = {};
  bool _showResults = false;
  bool _autoNext = true;
  int _correctCount = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _totalCount = widget.questions.length;
    // 初始化用户答案
    for (var question in widget.questions) {
      switch (question.type) {
        case QuestionType.multipleChoice:
          _userAnswers[question.id] = null;
          _isCorrect[question.id] = false;
          break;
        case QuestionType.trueFalse:
          _userAnswers[question.id] = null;
          _isCorrect[question.id] = false;
          break;
        case QuestionType.fillInTheBlank:
          _userAnswers[question.id] = <String>[];
          _isCorrect[question.id] = false;
          break;
        case QuestionType.shortAnswer:
          _userAnswers[question.id] = '';
          _isCorrect[question.id] = false;
          break;
      }
    }
  }

  Question get _currentQuestion => widget.questions[_currentQuestionIndex];

  void _handleAnswerChanged(dynamic answer) {
    setState(() {
      _userAnswers[_currentQuestion.id] = answer;
      
      // 立即判断对错
      bool isCorrect = false;
      switch (_currentQuestion.type) {
        case QuestionType.multipleChoice:
          final mcq = _currentQuestion as MultipleChoiceQuestion;
          isCorrect = answer == mcq.correctAnswerIndex;
          break;
        case QuestionType.trueFalse:
          final tfq = _currentQuestion as TrueFalseQuestion;
          isCorrect = answer == tfq.correctAnswer;
          break;
        // 填空题和简答题需要手动标记完成
        default:
          isCorrect = false;
      }
      
      // 更新正确题数
      bool wasCorrect = _isCorrect[_currentQuestion.id] ?? false;
      _isCorrect[_currentQuestion.id] = isCorrect;
      _answeredQuestions.add(_currentQuestion.id);
      
      if (isCorrect && !wasCorrect) {
        _correctCount++;
      } else if (!isCorrect && wasCorrect) {
        _correctCount--;
      }
      
      // 如果设置了自动跳题且答案正确，自动跳转到下一题
      if (_autoNext && isCorrect && _currentQuestionIndex < widget.questions.length - 1) {
        _nextQuestion();
      }
    });
  }

  void _markAsAnswered() {
    setState(() {
      _answeredQuestions.add(_currentQuestion.id);
      
      // 手动标记完成时判断对错
      bool isCorrect = false;
      switch (_currentQuestion.type) {
        case QuestionType.fillInTheBlank:
          final fibq = _currentQuestion as FillInTheBlankQuestion;
          final userAnswers = _userAnswers[_currentQuestion.id] as List<String>;
          if (userAnswers.length == fibq.correctAnswers.length) {
            isCorrect = true;
            for (int i = 0; i < userAnswers.length; i++) {
              if (userAnswers[i] != fibq.correctAnswers[i]) {
                isCorrect = false;
                break;
              }
            }
          }
          break;
        case QuestionType.shortAnswer:
          // 简答题暂不自动判断对错
          isCorrect = false;
          break;
        default:
          // 选择题和判断题已经在_handleAnswerChanged中判断过
          isCorrect = _isCorrect[_currentQuestion.id] ?? false;
      }
      
      // 更新正确题数
      bool wasCorrect = _isCorrect[_currentQuestion.id] ?? false;
      _isCorrect[_currentQuestion.id] = isCorrect;
      
      if (isCorrect && !wasCorrect) {
        _correctCount++;
      } else if (!isCorrect && wasCorrect) {
        _correctCount--;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _finishQuiz() {
    // 计算正确率
    int correctCount = 0;
    for (var entry in _isCorrect.entries) {
      if (entry.value) {
        correctCount++;
      }
    }
    
    setState(() {
      _correctCount = correctCount;
      _showResults = true;
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _userAnswers.clear();
      _isCorrect.clear();
      _answeredQuestions.clear();
      _showResults = false;
      _autoNext = false;
      _correctCount = 0;
      
      // 重新初始化用户答案
      for (var question in widget.questions) {
        switch (question.type) {
          case QuestionType.multipleChoice:
            _userAnswers[question.id] = null;
            _isCorrect[question.id] = false;
            break;
          case QuestionType.trueFalse:
            _userAnswers[question.id] = null;
            _isCorrect[question.id] = false;
            break;
          case QuestionType.fillInTheBlank:
            _userAnswers[question.id] = <String>[];
            _isCorrect[question.id] = false;
            break;
          case QuestionType.shortAnswer:
            _userAnswers[question.id] = '';
            _isCorrect[question.id] = false;
            break;
        }
      }
    });
  }

  // 切换自动跳题开关
  void _toggleAutoNext() {
    setState(() {
      _autoNext = !_autoNext;
    });
  }

  // 显示答题卡
  void _showAnswerCard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('答题卡'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 答题卡标题和统计
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '共 ${widget.questions.length} 题',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      _buildStatusIndicator('已答', _answeredQuestions.length, Colors.blue),
                      const SizedBox(width: 16),
                      _buildStatusIndicator('正确', _correctCount, Colors.green),
                      const SizedBox(width: 16),
                      _buildStatusIndicator('错误', _answeredQuestions.length - _correctCount, Colors.red),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 题目状态网格
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  final question = widget.questions[index];
                  final isAnswered = _answeredQuestions.contains(question.id);
                  final isCorrect = _isCorrect[question.id] ?? false;
                  final isCurrent = index == _currentQuestionIndex;

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentQuestionIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isCurrent
                            ? Colors.yellow.withOpacity(0.3)
                            : isAnswered
                                ? isCorrect
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.red.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.3),
                        border: Border.all(
                          color: isCurrent
                              ? Colors.yellow
                              : isAnswered
                                  ? isCorrect
                                      ? Colors.green
                                      : Colors.red
                                  : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCurrent
                                ? Colors.yellow[800] as Color
                                : isAnswered
                                    ? isCorrect
                                        ? Colors.green
                                        : Colors.red
                                    : Colors.grey[600] as Color,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // 图例说明
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('当前题', Colors.yellow),
                  const SizedBox(width: 16),
                  _buildLegendItem('正确', Colors.green),
                  const SizedBox(width: 16),
                  _buildLegendItem('错误', Colors.red),
                  const SizedBox(width: 16),
                  _buildLegendItem('未答', Colors.grey),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _finishQuiz();
            },
            child: const Text('完成练习'),
          ),
        ],
      ),
    );
  }

  // 构建状态指示器
  Widget _buildStatusIndicator(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text('$label: $count'),
      ],
    );
  }

  // 构建图例项
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: color.withOpacity(0.3),
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildQuizContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 顶部导航栏
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('答题'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('背题'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('语音'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.fullscreen),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.nightlight_round),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 题目编号和进度
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_currentQuestionIndex + 1} / ${widget.questions.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            // 自动跳题开关
            Row(
              children: [
                const Text('自动跳题'),
                Switch(
                  value: _autoNext,
                  onChanged: (value) => _toggleAutoNext(),
                  activeColor: Colors.blue,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 题目类型
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.blue.withOpacity(0.1),
          ),
          child: Text(
            _getQuestionTypeText(_currentQuestion.type),
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: 16),
        // 题目内容
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentQuestion.content,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 24),
                QuestionWidget(
                  question: _currentQuestion,
                  userAnswer: _userAnswers[_currentQuestion.id],
                  onAnswerChanged: _handleAnswerChanged,
                  showCorrectAnswer: _answeredQuestions.contains(_currentQuestion.id),
                  isAnswered: _answeredQuestions.contains(_currentQuestion.id),
                ),
                // 答案显示
                if (_answeredQuestions.contains(_currentQuestion.id)) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '正确答案: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getCorrectAnswerText(_currentQuestion),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              '您的选择: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getUserAnswerText(_currentQuestion),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isCorrect[_currentQuestion.id] ?? false
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 试题详解
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '试题详解',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.error_outline),
                              label: const Text('纠错'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_currentQuestion.explanation != null) ...[
                          Text(_currentQuestion.explanation!),
                        ] else
                          const Text('暂无解析'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // 底部操作按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: _previousQuestion,
              icon: const Icon(Icons.chevron_left),
              label: const Text('上一题'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
            ),
            if (!_answeredQuestions.contains(_currentQuestion.id))
              ElevatedButton.icon(
                onPressed: () {
                  _markAsAnswered();
                },
                icon: const Icon(Icons.check),
                label: const Text('标记完成'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    if (_isCorrect[_currentQuestion.id] ?? false) {
                      _correctCount--;
                    }
                    _answeredQuestions.remove(_currentQuestion.id);
                    _isCorrect[_currentQuestion.id] = false;
                  });
                },
                icon: const Icon(Icons.edit),
                label: const Text('重新答题'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            ElevatedButton.icon(
              onPressed: _nextQuestion,
              icon: const Icon(Icons.chevron_right),
              label: const Text('下一题'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // 底部功能按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.share),
              tooltip: '分享',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.star_border),
              tooltip: '收藏',
            ),
            IconButton(
              onPressed: _showAnswerCard,
              icon: const Icon(Icons.grid_view),
              tooltip: '答题卡',
            ),
          ],
        ),
      ],
    );
  }

  // 获取正确答案文本
  String _getCorrectAnswerText(Question question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        final mcq = question as MultipleChoiceQuestion;
        return String.fromCharCode(65 + mcq.correctAnswerIndex);
      case QuestionType.trueFalse:
        final tfq = question as TrueFalseQuestion;
        return tfq.correctAnswer ? '对' : '错';
      case QuestionType.fillInTheBlank:
        final fibq = question as FillInTheBlankQuestion;
        return fibq.correctAnswers.join('、');
      case QuestionType.shortAnswer:
        final saq = question as ShortAnswerQuestion;
        return saq.referenceAnswer;
    }
  }

  // 获取用户答案文本
  String _getUserAnswerText(Question question) {
    final userAnswer = _userAnswers[question.id];
    if (userAnswer == null || (userAnswer is List && userAnswer.isEmpty) || (userAnswer is String && userAnswer.isEmpty)) {
      return '/';
    }
    
    switch (question.type) {
      case QuestionType.multipleChoice:
        return String.fromCharCode(65 + (userAnswer as int));
      case QuestionType.trueFalse:
        return (userAnswer as bool) ? '对' : '错';
      case QuestionType.fillInTheBlank:
        return (userAnswer as List<String>).join('、');
      case QuestionType.shortAnswer:
        return userAnswer as String;
    }
  }

  Widget _buildResults() {
    final answeredCount = _answeredQuestions.length;
    final correctCount = _correctCount;
    final totalCount = widget.questions.length;
    final completionRate = (answeredCount / totalCount * 100).round();
    final accuracy = totalCount > 0 ? (correctCount / totalCount * 100).round() : 0;
    final incorrectCount = totalCount - correctCount;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.celebration,
          size: 80,
          color: Colors.green,
        ),
        const SizedBox(height: 24),
        Text(
          '练习完成！',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildResultItem('总题目数', totalCount.toString()),
                const Divider(height: 24),
                _buildResultItem('完成题目', '$answeredCount/$totalCount'),
                const Divider(height: 24),
                _buildResultItem('正确题目', '$correctCount/$totalCount', isHighlighted: true),
                const Divider(height: 24),
                _buildResultItem('错误题目', '$incorrectCount/$totalCount'),
                const Divider(height: 24),
                _buildResultItem('完成率', '$completionRate%'),
                const Divider(height: 24),
                _buildResultItem('正确率', '$accuracy%', isHighlighted: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _restartQuiz,
          icon: const Icon(Icons.restart_alt),
          label: const Text('重新练习'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 50),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.home),
          label: const Text('返回主页'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            minimumSize: const Size(200, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildResultItem(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 24 : 18,
            fontWeight: FontWeight.bold,
            color: isHighlighted ? Colors.blue : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
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
        title: Text(widget.title),
        actions: [
          if (!_showResults)
            TextButton.icon(
              onPressed: _finishQuiz,
              icon: const Icon(Icons.done_all, color: Colors.white),
              label: const Text('完成', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _showResults ? _buildResults() : _buildQuizContent(),
      ),
    );
  }
}