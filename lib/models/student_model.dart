class StudentModel {
  final String id;
  final String apaarId;
  final String name;
  final int grade;
  final String section;
  final String rollNumber;
  final String enrolledSchoolUdise;
  final DateTime dateOfBirth;
  final double attendancePercentage;

  StudentModel({
    required this.id,
    required this.apaarId,
    required this.name,
    required this.grade,
    this.section = '',
    this.rollNumber = '',
    required this.enrolledSchoolUdise,
    required this.dateOfBirth,
    this.attendancePercentage = 0.0,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return StudentModel(
      id: docId ?? json['id'] ?? json['apaarId'] ?? '',
      apaarId: json['apaarId'] ?? docId ?? '',
      name: json['name'] ?? '',
      grade: json['grade'] ?? 0,
      section: json['section'] ?? '',
      rollNumber: json['rollNumber'] ?? '',
      enrolledSchoolUdise: json['enrolledSchoolUdise'] ?? '',
      dateOfBirth: DateTime.tryParse(json['dateOfBirth']?.toString() ?? '') ??
          DateTime(2010),
      attendancePercentage: (json['attendancePercentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apaarId': apaarId,
      'name': name,
      'grade': grade,
      'section': section,
      'rollNumber': rollNumber,
      'enrolledSchoolUdise': enrolledSchoolUdise,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'attendancePercentage': attendancePercentage,
    };
  }
}
