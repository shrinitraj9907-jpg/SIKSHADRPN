class StudentModel {
  final String apaarId; // Unique Automated Permanent Academic Account Registry ID
  final String name;
  final int grade;
  final String enrolledSchoolUdise;
  final DateTime dateOfBirth;
  final double attendancePercentage;

  StudentModel({
    required this.apaarId,
    required this.name,
    required this.grade,
    required this.enrolledSchoolUdise,
    required this.dateOfBirth,
    this.attendancePercentage = 0.0,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      apaarId: json['apaarId'],
      name: json['name'],
      grade: json['grade'],
      enrolledSchoolUdise: json['enrolledSchoolUdise'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      attendancePercentage: json['attendancePercentage']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apaarId': apaarId,
      'name': name,
      'grade': grade,
      'enrolledSchoolUdise': enrolledSchoolUdise,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'attendancePercentage': attendancePercentage,
    };
  }
}
