// lib/models/homework_model.dart

enum HomeworkStatus { pending, submitted, late, graded }

class HomeworkModel {
  final String id;
  final String teacherId;
  final String teacherName;
  final String schoolUdise;
  final int grade;
  final String section;
  final String subject;
  final String title;
  final String description;
  final DateTime assignedDate;
  final DateTime dueDate;
  final String? attachmentUrl;

  HomeworkModel({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.schoolUdise,
    required this.grade,
    required this.section,
    required this.subject,
    required this.title,
    required this.description,
    required this.assignedDate,
    required this.dueDate,
    this.attachmentUrl,
  });

  bool get isOverdue => DateTime.now().isAfter(dueDate);

  factory HomeworkModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return HomeworkModel(
      id: docId ?? json['id'] ?? '',
      teacherId: json['teacherId'] ?? '',
      teacherName: json['teacherName'] ?? '',
      schoolUdise: json['schoolUdise'] ?? '',
      grade: json['grade'] ?? 0,
      section: json['section'] ?? 'A',
      subject: json['subject'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      assignedDate:
          DateTime.tryParse(json['assignedDate'] ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(json['dueDate'] ?? '') ??
          DateTime.now().add(const Duration(days: 1)),
      attachmentUrl: json['attachmentUrl'],
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
        'description': description,
        'assignedDate': assignedDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'attachmentUrl': attachmentUrl,
      };
}

class HomeworkSubmissionModel {
  final String id;
  final String homeworkId;
  final String studentId;
  final String studentName;
  final DateTime submittedAt;
  final HomeworkStatus status;
  final String? photoUrl;
  final String? teacherRemarks;
  final int? marksObtained;

  HomeworkSubmissionModel({
    required this.id,
    required this.homeworkId,
    required this.studentId,
    required this.studentName,
    required this.submittedAt,
    this.status = HomeworkStatus.submitted,
    this.photoUrl,
    this.teacherRemarks,
    this.marksObtained,
  });

  factory HomeworkSubmissionModel.fromJson(Map<String, dynamic> json,
      {String? docId}) {
    return HomeworkSubmissionModel(
      id: docId ?? json['id'] ?? '',
      homeworkId: json['homeworkId'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      submittedAt:
          DateTime.tryParse(json['submittedAt'] ?? '') ?? DateTime.now(),
      status: HomeworkStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => HomeworkStatus.pending),
      photoUrl: json['photoUrl'],
      teacherRemarks: json['teacherRemarks'],
      marksObtained: json['marksObtained'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'homeworkId': homeworkId,
        'studentId': studentId,
        'studentName': studentName,
        'submittedAt': submittedAt.toIso8601String(),
        'status': status.name,
        'photoUrl': photoUrl,
        'teacherRemarks': teacherRemarks,
        'marksObtained': marksObtained,
      };
}
