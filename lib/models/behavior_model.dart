// lib/models/behavior_model.dart

enum RemarkType { positive, negative, neutral }
enum ConductGrade { excellent, good, satisfactory, needsImprovement, poor }
enum IncidentSeverity { low, medium, high, critical }

class BehaviorRemarkModel {
  final String id;
  final String studentId;
  final String teacherId;
  final String teacherName;
  final RemarkType type;
  final String remark;
  final DateTime date;
  final String? term; // Term 1, Term 2

  BehaviorRemarkModel({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.teacherName,
    required this.type,
    required this.remark,
    required this.date,
    this.term,
  });

  factory BehaviorRemarkModel.fromJson(Map<String, dynamic> json,
      {String? docId}) {
    return BehaviorRemarkModel(
      id: docId ?? json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      teacherId: json['teacherId'] ?? '',
      teacherName: json['teacherName'] ?? '',
      type: RemarkType.values.firstWhere((e) => e.name == json['type'],
          orElse: () => RemarkType.neutral),
      remark: json['remark'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      term: json['term'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'type': type.name,
        'remark': remark,
        'date': date.toIso8601String(),
        'term': term,
      };
}

class IncidentReportModel {
  final String id;
  final String studentId;
  final String reportedByTeacherId;
  final String reportedByTeacherName;
  final IncidentSeverity severity;
  final String title;
  final String description;
  final DateTime date;
  final String? actionTaken;
  bool resolved;

  IncidentReportModel({
    required this.id,
    required this.studentId,
    required this.reportedByTeacherId,
    required this.reportedByTeacherName,
    required this.severity,
    required this.title,
    required this.description,
    required this.date,
    this.actionTaken,
    this.resolved = false,
  });

  factory IncidentReportModel.fromJson(Map<String, dynamic> json,
      {String? docId}) {
    return IncidentReportModel(
      id: docId ?? json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      reportedByTeacherId: json['reportedByTeacherId'] ?? '',
      reportedByTeacherName: json['reportedByTeacherName'] ?? '',
      severity: IncidentSeverity.values.firstWhere(
          (e) => e.name == json['severity'],
          orElse: () => IncidentSeverity.low),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      actionTaken: json['actionTaken'],
      resolved: json['resolved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'reportedByTeacherId': reportedByTeacherId,
        'reportedByTeacherName': reportedByTeacherName,
        'severity': severity.name,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'actionTaken': actionTaken,
        'resolved': resolved,
      };
}

class ConductRecordModel {
  final String id;
  final String studentId;
  final String term;
  final int academicYear;
  final ConductGrade conductGrade;
  final String? remarks;
  final DateTime updatedAt;
  final String updatedByTeacherId;

  ConductRecordModel({
    required this.id,
    required this.studentId,
    required this.term,
    required this.academicYear,
    required this.conductGrade,
    this.remarks,
    required this.updatedAt,
    required this.updatedByTeacherId,
  });

  factory ConductRecordModel.fromJson(Map<String, dynamic> json,
      {String? docId}) {
    return ConductRecordModel(
      id: docId ?? json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      term: json['term'] ?? 'Term 1',
      academicYear: json['academicYear'] ?? DateTime.now().year,
      conductGrade: ConductGrade.values.firstWhere(
          (e) => e.name == json['conductGrade'],
          orElse: () => ConductGrade.good),
      remarks: json['remarks'],
      updatedAt:
          DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      updatedByTeacherId: json['updatedByTeacherId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'term': term,
        'academicYear': academicYear,
        'conductGrade': conductGrade.name,
        'remarks': remarks,
        'updatedAt': updatedAt.toIso8601String(),
        'updatedByTeacherId': updatedByTeacherId,
      };
}
