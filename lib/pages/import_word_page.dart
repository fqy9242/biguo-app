import 'package:flutter/material.dart';
import '../models/lib/models.dart';

class ImportWordPage extends StatefulWidget {
  final QuizBank questionBank;
  final Function(List<Question>) onQuestionsImported;

  const ImportWordPage({
    Key? key,
    required this.questionBank,
    required this.onQuestionsImported,
  }) : super(key: key);

  @override
  State<ImportWordPage> createState() => _ImportWordPageState();
}

class _ImportWordPageState extends State<ImportWordPage> {
  String? _selectedFilePath;
  bool _isImporting = false;
  String _importStatus = '';
  List<Question>? _importedQuestions;

  // 模拟从Word导入题目（占位符）
  Future<void> _importFromWord() async {
    if (_selectedFilePath == null) {
      setState(() {
        _importStatus = '请选择Word文件';
      });
      return;
    }

    setState(() {
      _isImporting = true;
      _importStatus = '正在导入...';
      _importedQuestions = null;
    });

    try {
      // TODO: 实现Word导入功能，调用后端API
      // 示例API调用：final result = await api.importQuestionsFromWord(_selectedFilePath!);
      
      // 模拟API调用延迟
      await Future.delayed(const Duration(seconds: 2));
      
      // 模拟导入结果
      final mockQuestions = _generateMockQuestions();
      
      setState(() {
        _importStatus = '导入成功！共导入 ${mockQuestions.length} 道题目';
        _importedQuestions = mockQuestions;
      });
    } catch (e) {
      setState(() {
        _importStatus = '导入失败：$e';
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  // 生成模拟题目数据
  List<Question> _generateMockQuestions() {
    return [
      MultipleChoiceQuestion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '以下哪个是Flutter的特点？',
        difficulty: Difficulty.medium,
        options: [
          '跨平台开发',
          '仅支持iOS',
          '仅支持Android',
          '需要原生代码开发',
        ],
        correctAnswerIndex: 0,
        explanation: 'Flutter是一个跨平台的UI框架，可以使用一套代码构建iOS、Android、Web和桌面应用。',
      ),
      TrueFalseQuestion(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: 'Dart是Flutter使用的编程语言。',
        difficulty: Difficulty.easy,
        correctAnswer: true,
        explanation: 'Flutter使用Dart作为开发语言，Dart是一种面向对象的编程语言。',
      ),
      FillInTheBlankQuestion(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        content: 'Flutter的核心概念是________和________。',
        difficulty: Difficulty.medium,
        correctAnswers: ['Widget', 'State'],
        explanation: 'Flutter的UI是由Widget构建的，State管理着Widget的动态数据。',
      ),
      ShortAnswerQuestion(
        id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
        content: '请简要说明Flutter的热重载功能。',
        difficulty: Difficulty.hard,
        referenceAnswer: 'Flutter的热重载功能允许开发者在不重启应用的情况下，将代码更改实时应用到运行中的应用上，大大提高了开发效率。',
        explanation: '热重载通过替换应用的Widget树来实现，保留应用的状态，使开发者能够快速看到代码更改的效果。',
      ),
    ];
  }

  // 选择Word文件（占位符）
  void _selectWordFile() {
    // TODO: 实现文件选择功能
    // 示例：final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['docx']);
    
    setState(() {
      _selectedFilePath = '示例文件.docx';
      _importStatus = '已选择文件：$_selectedFilePath';
    });
  }

  // 确认导入题目
  void _confirmImport() {
    if (_importedQuestions != null && _importedQuestions!.isNotEmpty) {
      widget.onQuestionsImported(_importedQuestions!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word导入'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '从Word文档导入题目',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '请确保Word文档中的题目格式符合要求：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormatExample('选择题', '1. 题目内容\nA. 选项1\nB. 选项2\nC. 选项3\nD. 选项4\n答案：A'),
                    _buildFormatExample('判断题', '2. 题目内容\n答案：对'),
                    _buildFormatExample('填空题', '3. 题目内容________和________\n答案：答案1，答案2'),
                    _buildFormatExample('简答题', '4. 题目内容\n答案：参考答案内容'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedFilePath != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('已选择文件：', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_selectedFilePath!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: _selectWordFile,
              icon: const Icon(Icons.file_upload),
              label: const Text('选择Word文件'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isImporting ? null : _importFromWord,
              icon: _isImporting ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ) : const Icon(Icons.import_export),
              label: Text(_isImporting ? '导入中...' : '开始导入'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 16),
            if (_importStatus.isNotEmpty) ...[
              Card(
                color: _importStatus.contains('成功') ? Colors.green.withOpacity(0.1) : 
                       _importStatus.contains('失败') ? Colors.red.withOpacity(0.1) : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _importStatus,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _importStatus.contains('成功') ? Colors.green : 
                             _importStatus.contains('失败') ? Colors.red : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_importedQuestions != null && _importedQuestions!.isNotEmpty) ...[
              Text(
                '导入的题目列表：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _importedQuestions!.length,
                    itemBuilder: (context, index) {
                      final question = _importedQuestions![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ${question.content}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '类型：${question.type == QuestionType.multipleChoice ? '选择题' : 
                                      question.type == QuestionType.trueFalse ? '判断题' :
                                      question.type == QuestionType.fillInTheBlank ? '填空题' : '简答题'}',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _confirmImport,
                icon: const Icon(Icons.check),
                label: const Text('确认导入'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormatExample(String type, String example) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type, 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              example,
              style: const TextStyle(fontFamily: 'Courier New'),
            ),
          ],
        ),
      ),
    );
  }
}