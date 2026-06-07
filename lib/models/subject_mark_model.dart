class SubjectMarkModel {
  final String id;
  final String subjectName;
  final double obtainedMarks;
  final double totalMarks;
  final String teacherId;
  final String teacherName;
  final DateTime? updatedAt;

  SubjectMarkModel({
    required this.id,
    required this.subjectName,
    required this.obtainedMarks,
    required this.totalMarks,
    required this.teacherId,
    this.teacherName = '',
    this.updatedAt,
  });

  double get percentage =>
      totalMarks > 0 ? (obtainedMarks / totalMarks) * 100 : 0;

  factory SubjectMarkModel.fromJson(Map<String, dynamic> json) {
    return SubjectMarkModel(
      id: json['id'] ?? '',
      subjectName: json['subjectName'] ?? '',
      obtainedMarks: (json['obtainedMarks'] ?? 0).toDouble(),
      totalMarks: (json['totalMarks'] ?? 100).toDouble(),
      teacherId: json['teacherId'] ?? '',
      teacherName: json['teacherName'] ?? '',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectName': subjectName,
        'obtainedMarks': obtainedMarks,
        'totalMarks': totalMarks,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
      };

  SubjectMarkModel copyWith({
    String? id,
    String? subjectName,
    double? obtainedMarks,
    double? totalMarks,
    String? teacherId,
    String? teacherName,
    DateTime? updatedAt,
  }) {
    return SubjectMarkModel(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      totalMarks: totalMarks ?? this.totalMarks,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
