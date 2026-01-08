import 'dart:convert';

// 题目类型枚举
enum QuestionType {
  multipleChoice,
  trueFalse,
  fillInTheBlank,
  shortAnswer,
}

// 题目难度枚举
enum Difficulty {
  easy,
  medium,
  hard,
}

// 题目基类
abstract class Question {
  String id;
  String content;
  QuestionType type;
  Difficulty difficulty;
  String? explanation;
  String? bankId; // 所属题库ID
  DateTime createdAt;
  DateTime updatedAt;

  Question({
    required this.id,
    required this.content,
    required this.type,
    required this.difficulty,
    this.explanation,
    this.bankId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson();

  factory Question.fromJson(Map<String, dynamic> json) {
    switch (QuestionType.values.byName(json['type'])) {
      case QuestionType.multipleChoice:
        return MultipleChoiceQuestion.fromJson(json);
      case QuestionType.trueFalse:
        return TrueFalseQuestion.fromJson(json);
      case QuestionType.fillInTheBlank:
        return FillInTheBlankQuestion.fromJson(json);
      case QuestionType.shortAnswer:
        return ShortAnswerQuestion.fromJson(json);
      default:
        throw UnsupportedError('Unknown question type');
    }
  }
}

// 选择题
class MultipleChoiceQuestion extends Question {
  List<String> options;
  int correctAnswerIndex;

  MultipleChoiceQuestion({
    required super.id,
    required super.content,
    required super.difficulty,
    required this.options,
    required this.correctAnswerIndex,
    super.explanation,
    super.bankId,
    super.createdAt,
    super.updatedAt,
  }) : super(type: QuestionType.multipleChoice);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'difficulty': difficulty.name,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'bankId': bankId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MultipleChoiceQuestion.fromJson(Map<String, dynamic> json) {
    return MultipleChoiceQuestion(
      id: json['id'],
      content: json['content'],
      difficulty: Difficulty.values.byName(json['difficulty']),
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
      explanation: json['explanation'],
      bankId: json['bankId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// 判断题
class TrueFalseQuestion extends Question {
  bool correctAnswer;

  TrueFalseQuestion({
    required super.id,
    required super.content,
    required super.difficulty,
    required this.correctAnswer,
    super.explanation,
    super.bankId,
    super.createdAt,
    super.updatedAt,
  }) : super(type: QuestionType.trueFalse);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'difficulty': difficulty.name,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'bankId': bankId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TrueFalseQuestion.fromJson(Map<String, dynamic> json) {
    return TrueFalseQuestion(
      id: json['id'],
      content: json['content'],
      difficulty: Difficulty.values.byName(json['difficulty']),
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
      bankId: json['bankId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// 填空题
class FillInTheBlankQuestion extends Question {
  List<String> correctAnswers;
  List<String> blanks;

  FillInTheBlankQuestion({
    required super.id,
    required super.content,
    required super.difficulty,
    required this.correctAnswers,
    this.blanks = const [],
    super.explanation,
    super.bankId,
    super.createdAt,
    super.updatedAt,
  }) : super(type: QuestionType.fillInTheBlank);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'difficulty': difficulty.name,
      'correctAnswers': correctAnswers,
      'blanks': blanks,
      'explanation': explanation,
      'bankId': bankId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FillInTheBlankQuestion.fromJson(Map<String, dynamic> json) {
    return FillInTheBlankQuestion(
      id: json['id'],
      content: json['content'],
      difficulty: Difficulty.values.byName(json['difficulty']),
      correctAnswers: List<String>.from(json['correctAnswers']),
      blanks: List<String>.from(json['blanks']),
      explanation: json['explanation'],
      bankId: json['bankId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// 简答题
class ShortAnswerQuestion extends Question {
  String referenceAnswer;

  ShortAnswerQuestion({
    required super.id,
    required super.content,
    required super.difficulty,
    required this.referenceAnswer,
    super.explanation,
    super.bankId,
    super.createdAt,
    super.updatedAt,
  }) : super(type: QuestionType.shortAnswer);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'difficulty': difficulty.name,
      'referenceAnswer': referenceAnswer,
      'explanation': explanation,
      'bankId': bankId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ShortAnswerQuestion.fromJson(Map<String, dynamic> json) {
    return ShortAnswerQuestion(
      id: json['id'],
      content: json['content'],
      difficulty: Difficulty.values.byName(json['difficulty']),
      referenceAnswer: json['referenceAnswer'],
      explanation: json['explanation'],
      bankId: json['bankId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// 题库类
class QuizBank {
  String id;
  String name;
  String? description;
  DateTime createdAt;
  DateTime updatedAt;
  List<Question> questions;

  QuizBank({
    required this.id,
    required this.name,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Question>? questions,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        questions = questions ?? [];

  // 添加题目
  void addQuestion(Question question) {
    questions.add(question);
  }

  // 删除题目
  void removeQuestion(String id) {
    questions.removeWhere((q) => q.id == id);
  }

  // 更新题目
  void updateQuestion(Question updatedQuestion) {
    final index = questions.indexWhere((q) => q.id == updatedQuestion.id);
    if (index != -1) {
      questions[index] = updatedQuestion;
    }
  }

  // 根据ID获取题目
  Question? getQuestionById(String id) {
    return questions.firstWhere((q) => q.id == id, orElse: () => null as Question);
  }

  // 获取所有题目
  List<Question> getAllQuestions() {
    return [...questions];
  }

  // 根据类型获取题目
  List<Question> getQuestionsByType(QuestionType type) {
    return questions.where((q) => q.type == type).toList();
  }

  // 根据难度获取题目
  List<Question> getQuestionsByDifficulty(Difficulty difficulty) {
    return questions.where((q) => q.difficulty == difficulty).toList();
  }

  // 清空题库
  void clear() {
    questions.clear();
  }

  // 导入题目列表
  void importQuestions(List<Question> newQuestions) {
    questions.addAll(newQuestions);
  }

  // 导出题目列表
  List<Map<String, dynamic>> exportQuestions() {
    return questions.map((q) => q.toJson()).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  factory QuizBank.fromJson(Map<String, dynamic> json) {
    return QuizBank(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      questions: (json['questions'] as List)
          .map((qJson) => Question.fromJson(qJson as Map<String, dynamic>))
          .toList(),
    );
  }
}

// 题库管理类
class QuizBankManager {
  List<QuizBank> quizBanks = [];

  // 添加题库
  void addQuizBank(QuizBank quizBank) {
    quizBanks.add(quizBank);
  }

  // 删除题库
  void removeQuizBank(String id) {
    quizBanks.removeWhere((bank) => bank.id == id);
  }

  // 更新题库
  void updateQuizBank(QuizBank updatedBank) {
    final index = quizBanks.indexWhere((bank) => bank.id == updatedBank.id);
    if (index != -1) {
      quizBanks[index] = updatedBank;
    }
  }

  // 根据ID获取题库
  QuizBank? getQuizBankById(String id) {
    return quizBanks.firstWhere((bank) => bank.id == id, orElse: () => null as QuizBank);
  }

  // 获取所有题库
  List<QuizBank> getAllQuizBanks() {
    return [...quizBanks];
  }

  // 通过Word导入题目到指定题库（占位符）
  Future<void> importFromWord(String filePath, String bankId) async {
    // TODO: 实现Word导入功能，调用后端API
    // 示例API调用：await api.importQuestionsFromWord(filePath, bankId);
    print('从Word导入题目到题库 $bankId：$filePath');
  }
}

