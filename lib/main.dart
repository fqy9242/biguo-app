import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/lib/models.dart';
import 'pages/quiz_page.dart';
import 'pages/question_bank_page.dart';
import 'pages/add_question_page.dart';
import 'pages/import_word_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '必过',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final QuizBankManager _bankManager = QuizBankManager();
  bool _isInitialized = false;
  String? _loggedInUser;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    _loadLoginStatus();
  }

  // 加载登录状态
  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('loggedInUser');
    if (username != null) {
      setState(() {
        _loggedInUser = username;
      });
    }
  }

  // 初始化模拟数据
  void _initializeMockData() {
    final mockBank1 = QuizBank(
      id: '1',
      name: '语文期末考试题库',
      description: '初中语文期末考试题目',
    );

    final mockBank2 = QuizBank(
      id: '2',
      name: 'Flutter基础题库',
      description: 'Flutter开发基础知识点',
    );

    final mockQuestions1 = [
      MultipleChoiceQuestion(
        id: '1',
        content: '以下哪个是Flutter的特点？',
        difficulty: Difficulty.medium,
        options: ['跨平台开发', '仅支持iOS', '仅支持Android', '需要原生代码开发'],
        correctAnswerIndex: 0,
        explanation: 'Flutter是一个跨平台的UI框架，可以使用一套代码构建iOS、Android、Web和桌面应用。',
        bankId: mockBank2.id,
      ),
      TrueFalseQuestion(
        id: '2',
        content: 'Dart是Flutter使用的编程语言。',
        difficulty: Difficulty.easy,
        correctAnswer: true,
        explanation: 'Flutter使用Dart作为开发语言，Dart是一种面向对象的编程语言。',
        bankId: mockBank2.id,
      ),
      FillInTheBlankQuestion(
        id: '3',
        content: 'Flutter的核心概念是________和________。',
        difficulty: Difficulty.medium,
        correctAnswers: ['Widget', 'State'],
        explanation: 'Flutter的UI是由Widget构建的，State管理着Widget的动态数据。',
        bankId: mockBank2.id,
      ),
      ShortAnswerQuestion(
        id: '4',
        content: '请简要说明Flutter的热重载功能。',
        difficulty: Difficulty.hard,
        referenceAnswer:
            'Flutter的热重载功能允许开发者在不重启应用的情况下，将代码更改实时应用到运行中的应用上，大大提高了开发效率。',
        explanation: '热重载通过替换应用的Widget树来实现，保留应用的状态，使开发者能够快速看到代码更改的效果。',
        bankId: mockBank2.id,
      ),
    ];

    final mockQuestions2 = [
      MultipleChoiceQuestion(
        id: '5',
        content: '下列哪个是唐代诗人？',
        difficulty: Difficulty.easy,
        options: ['李白', '苏轼', '辛弃疾', '李清照'],
        correctAnswerIndex: 0,
        explanation: '李白是唐代著名诗人，被称为"诗仙"。',
        bankId: mockBank1.id,
      ),
      TrueFalseQuestion(
        id: '6',
        content: '《静夜思》的作者是杜甫。',
        difficulty: Difficulty.easy,
        correctAnswer: false,
        explanation: '《静夜思》的作者是李白，不是杜甫。',
        bankId: mockBank1.id,
      ),
    ];

    mockBank1.importQuestions(mockQuestions1);
    mockBank2.importQuestions(mockQuestions2);

    _bankManager.addQuizBank(mockBank1);
    _bankManager.addQuizBank(mockBank2);

    setState(() {
      _isInitialized = true;
    });
  }

  // 创建新题库
  void _createNewQuizBank() {
    String bankName = '';
    String bankDescription = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建新题库'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '题库名称',
                hintText: '请输入题库名称',
              ),
              onChanged: (value) => bankName = value,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '题库描述（可选）',
                hintText: '请输入题库描述',
              ),
              onChanged: (value) => bankDescription = value,
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (bankName.isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('请输入题库名称')));
                return;
              }

              final newBank = QuizBank(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: bankName,
                description: bankDescription.isEmpty ? null : bankDescription,
              );

              _bankManager.addQuizBank(newBank);
              Navigator.pop(context);
              setState(() {});
              _showMessage('新题库创建成功');
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  // 导航到刷题页面
  void _navigateToQuiz(QuizBank bank) {
    final questions = bank.getAllQuestions();
    if (questions.isEmpty) {
      _showMessage('该题库为空，请先添加题目');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QuizPage(questions: questions, title: '练习 - ${bank.name}'),
      ),
    );
  }

  // 导航到题库管理页面
  void _navigateToQuestionBank(QuizBank bank) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionBankPage(
          questionBank: bank,
          onQuestionAdded: (question) {
            bank.addQuestion(question);
          },
          onQuestionDeleted: (id) {
            bank.removeQuestion(id);
          },
          onQuestionUpdated: (question) {
            bank.updateQuestion(question);
          },
        ),
      ),
    ).then((_) => setState(() {}));
  }

  // 导航到Word导入页面
  void _navigateToImportWord(QuizBank bank) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImportWordPage(
          questionBank: bank,
          onQuestionsImported: (questions) {
            bank.importQuestions(questions);
            _showMessage('成功导入 ${questions.length} 道题目');
          },
        ),
      ),
    ).then((_) => setState(() {}));
  }

  // 显示消息
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  // 导航到登录页面
  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(onLoginSuccess: _handleLoginSuccess),
      ),
    );
  }

  // 处理登录成功
  Future<void> _handleLoginSuccess(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loggedInUser', username);
    setState(() {
      _loggedInUser = username;
    });
    _showMessage('登录成功，欢迎 $username');
  }

  // 处理登出
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInUser');
    setState(() {
      _loggedInUser = null;
    });
    _showMessage('已登出');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的学习空间'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        actions: [],
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                Expanded(
                  child: _bankManager.getAllQuizBanks().isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                child: const Icon(
                                  Icons.book,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                '暂无题库',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '创建一个新题库开始学习',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _bankManager.getAllQuizBanks().length,
                          itemBuilder: (context, index) {
                            final bank = _bankManager.getAllQuizBanks()[index];
                            final isRecent = index == 0; // 模拟最近学习
                            final isStarred =
                                index ==
                                _bankManager.getAllQuizBanks().length -
                                    1; // 模拟星标

                            return GestureDetector(
                              onTap: () => _navigateToQuiz(bank),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 左侧图标
                                      Container(
                                        margin: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: Colors.blue[100],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.menu_book,
                                                color: Colors.blue,
                                                size: 24,
                                              ),
                                            ),
                                            Positioned(
                                              bottom: -4,
                                              right: -4,
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: Colors.yellow,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.arrow_upward,
                                                  color: Colors.black,
                                                  size: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // 中间内容
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  bank.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                if (isStarred) ...[
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.yellow,
                                                    size: 16,
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                if (isRecent) ...[
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      '最近学习',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                ],
                                                Text(
                                                  '${bank.questions.length}道',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Text(
                                                  isRecent
                                                      ? '2026-01-08'
                                                      : '2025-12-31',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // 右侧操作按钮
                                      Column(
                                        children: [
                                          IconButton(
                                            onPressed: () {},
                                            icon: Icon(
                                              Icons.refresh,
                                              color: Colors.grey[500],
                                              size: 20,
                                            ),
                                            padding: EdgeInsets.zero,
                                          ),
                                          IconButton(
                                            onPressed: () {},
                                            icon: Icon(
                                              Icons.more_vert,
                                              color: Colors.grey[500],
                                              size: 20,
                                            ),
                                            padding: EdgeInsets.zero,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _createNewQuizBank,
                  icon: const Icon(Icons.add),
                  label: const Text('创建新题库'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // 根据索引切换不同的页面
            switch (index) {
              case 0:
                // 首页，保持当前页面
                break;
              case 1:
                // 个人中心页面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      loggedInUser: _loggedInUser,
                      onLogout: _handleLogout,
                    ),
                  ),
                );
                break;
            }
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }
}
