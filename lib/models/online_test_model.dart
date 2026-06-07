// lib/models/online_test_model.dart

enum QuestionType { singleChoice, multipleChoice, trueFalse }
enum TestStatus { draft, published, ongoing, completed }
enum DifficultyLevel { easy, medium, hard }

class MCQQuestionModel {
  final String id;
  final String questionText;
  final QuestionType type;
  final List<String> options;
  final List<int> correctOptionIndices; // 0-based index
  final DifficultyLevel difficulty;
  final int marks;
  final String? explanation;

  MCQQuestionModel({
    required this.id,
    required this.questionText,
    this.type = QuestionType.singleChoice,
    required this.options,
    required this.correctOptionIndices,
    this.difficulty = DifficultyLevel.medium,
    this.marks = 1,
    this.explanation,
  });

  factory MCQQuestionModel.fromJson(Map<String, dynamic> json,
      {String? docId}) {
    return MCQQuestionModel(
      id: docId ?? json['id'] ?? '',
      questionText: json['questionText'] ?? '',
      type: QuestionType.values.firstWhere((e) => e.name == json['type'],
          orElse: () => QuestionType.singleChoice),
      options: List<String>.from(json['options'] ?? []),
      correctOptionIndices:
          List<int>.from(json['correctOptionIndices'] ?? [0]),
      difficulty: DifficultyLevel.values.firstWhere(
          (e) => e.name == json['difficulty'],
          orElse: () => DifficultyLevel.medium),
      marks: json['marks'] ?? 1,
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'questionText': questionText,
        'type': type.name,
        'options': options,
        'correctOptionIndices': correctOptionIndices,
        'difficulty': difficulty.name,
        'marks': marks,
        'explanation': explanation,
      };
}

class OnlineTestModel {
  final String id;
  final String teacherId;
  final String teacherName;
  final String schoolUdise;
  final int grade;
  final String section;
  final String subject;
  final String title;
  final int durationMinutes;
  final DateTime scheduledAt;
  final TestStatus status;
  final List<MCQQuestionModel> questions;
  final bool randomizeQuestions;
  final int totalMarks;

  OnlineTestModel({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.schoolUdise,
    required this.grade,
    required this.section,
    required this.subject,
    required this.title,
    required this.durationMinutes,
    required this.scheduledAt,
    this.status = TestStatus.draft,
    this.questions = const [],
    this.randomizeQuestions = true,
    this.totalMarks = 0,
  });

  factory OnlineTestModel.fromJson(Map<String, dynamic> json,
      {String? docId}) {
    return OnlineTestModel(
      id: docId ?? json['id'] ?? '',
      teacherId: json['teacherId'] ?? '',
      teacherName: json['teacherName'] ?? '',
      schoolUdise: json['schoolUdise'] ?? '',
      grade: json['grade'] ?? 0,
      section: json['section'] ?? 'A',
      subject: json['subject'] ?? '',
      title: json['title'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 30,
      scheduledAt:
          DateTime.tryParse(json['scheduledAt'] ?? '') ?? DateTime.now(),
      status: TestStatus.values.firstWhere((e) => e.name == json['status'],
          orElse: () => TestStatus.draft),
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((q) => MCQQuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
      randomizeQuestions: json['randomizeQuestions'] ?? true,
      totalMarks: json['totalMarks'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'schoolUdise': schoolUdise,
        'grade': grade,
        'section': section,
        'subject': subject,
        'title': title,
        'durationMinutes': durationMinutes,
        'scheduledAt': scheduledAt.toIso8601String(),
        'status': status.name,
        'questions': questions.map((q) => q.toJson()).toList(),
        'randomizeQuestions': randomizeQuestions,
        'totalMarks': totalMarks,
      };
}

class TestAttemptModel {
  final String id;
  final String testId;
  final String studentId;
  final String studentName;
  final DateTime startedAt;
  DateTime? submittedAt;
  final Map<String, List<int>> answers; // questionId → selected option indices
  final int obtainedMarks;
  final double percentage;
  final bool isCompleted;

  TestAttemptModel({
    required this.id,
    required this.testId,
    required this.studentId,
    required this.studentName,
    required this.startedAt,
    this.submittedAt,
    this.answers = const {},
    this.obtainedMarks = 0,
    this.percentage = 0,
    this.isCompleted = false,
  });

  factory TestAttemptModel.fromJson(Map<String, dynamic> json,
      {String? docId}) {
    final rawAnswers = json['answers'] as Map<String, dynamic>? ?? {};
    final answers = rawAnswers.map((k, v) =>
        MapEntry(k, List<int>.from(v as List<dynamic>? ?? [])));
    return TestAttemptModel(
      id: docId ?? json['id'] ?? '',
      testId: json['testId'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      startedAt:
          DateTime.tryParse(json['startedAt'] ?? '') ?? DateTime.now(),
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'])
          : null,
      answers: answers,
      obtainedMarks: json['obtainedMarks'] ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'testId': testId,
        'studentId': studentId,
        'studentName': studentName,
        'startedAt': startedAt.toIso8601String(),
        'submittedAt': submittedAt?.toIso8601String(),
        'answers': answers,
        'obtainedMarks': obtainedMarks,
        'percentage': percentage,
        'isCompleted': isCompleted,
      };
}
