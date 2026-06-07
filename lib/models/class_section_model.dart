// lib/models/class_section_model.dart

class ClassModel {
  final String id; // e.g. "class_8"
  final int grade; // 1–12
  final String schoolUdise;
  final List<String> sectionIds;

  ClassModel({
    required this.id,
    required this.grade,
    required this.schoolUdise,
    this.sectionIds = const [],
  });

  String get displayName => 'Class $grade';

  factory ClassModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return ClassModel(
      id: docId ?? json['id'] ?? '',
      grade: json['grade'] ?? 0,
      schoolUdise: json['schoolUdise'] ?? '',
      sectionIds: List<String>.from(json['sectionIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'grade': grade,
        'schoolUdise': schoolUdise,
        'sectionIds': sectionIds,
      };
}

class SectionModel {
  final String id; // e.g. "class_8_A"
  final int grade;
  final String section; // A, B, C, D
  final String schoolUdise;
  final String classTeacherId;
  final String classTeacherName;
  final int maxStudents; // default 40
  final int totalBoys;
  final int totalGirls;
  final List<String> studentIds;

  SectionModel({
    required this.id,
    required this.grade,
    required this.section,
    required this.schoolUdise,
    this.classTeacherId = '',
    this.classTeacherName = '',
    this.maxStudents = 40,
    this.totalBoys = 0,
    this.totalGirls = 0,
    this.studentIds = const [],
  });

  int get totalStudents => totalBoys + totalGirls;
  String get displayName => 'Class $grade – $section';
  bool get isFull => totalStudents >= maxStudents;

  factory SectionModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return SectionModel(
      id: docId ?? json['id'] ?? '',
      grade: json['grade'] ?? 0,
      section: json['section'] ?? 'A',
      schoolUdise: json['schoolUdise'] ?? '',
      classTeacherId: json['classTeacherId'] ?? '',
      classTeacherName: json['classTeacherName'] ?? '',
      maxStudents: json['maxStudents'] ?? 40,
      totalBoys: json['totalBoys'] ?? 0,
      totalGirls: json['totalGirls'] ?? 0,
      studentIds: List<String>.from(json['studentIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'grade': grade,
        'section': section,
        'schoolUdise': schoolUdise,
        'classTeacherId': classTeacherId,
        'classTeacherName': classTeacherName,
        'maxStudents': maxStudents,
        'totalBoys': totalBoys,
        'totalGirls': totalGirls,
        'studentIds': studentIds,
      };
}
