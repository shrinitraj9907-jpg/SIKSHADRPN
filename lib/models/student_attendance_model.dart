enum AttendanceDayStatus {
  present,
  absent,
  holiday,
  unmarked,
}

extension AttendanceDayStatusX on AttendanceDayStatus {
  String get firestoreKey => name;

  static AttendanceDayStatus fromKey(String? key) {
    if (key == null) return AttendanceDayStatus.unmarked;
    return AttendanceDayStatus.values.firstWhere(
      (e) => e.name == key,
      orElse: () => AttendanceDayStatus.unmarked,
    );
  }
}

class StudentMonthlyAttendanceModel {
  final String id;
  final String studentId;
  final int year;
  final int month;
  final Map<int, AttendanceDayStatus> days;

  StudentMonthlyAttendanceModel({
    required this.id,
    required this.studentId,
    required this.year,
    required this.month,
    required this.days,
  });

  int get presentCount =>
      days.values.where((s) => s == AttendanceDayStatus.present).length;

  int get absentCount =>
      days.values.where((s) => s == AttendanceDayStatus.absent).length;

  int get holidayCount =>
      days.values.where((s) => s == AttendanceDayStatus.holiday).length;

  int get workingDays => presentCount + absentCount;

  double get attendancePercentage =>
      workingDays > 0 ? (presentCount / workingDays) * 100 : 100;

  bool get isBelowThreshold => workingDays > 0 && attendancePercentage < 75;

  factory StudentMonthlyAttendanceModel.fromJson(
    Map<String, dynamic> json, {
    String? studentId,
    String? docId,
  }) {
    final rawDays = json['days'] as Map<String, dynamic>? ?? {};
    final parsedDays = <int, AttendanceDayStatus>{};
    rawDays.forEach((key, value) {
      final day = int.tryParse(key);
      if (day != null) {
        parsedDays[day] = AttendanceDayStatusX.fromKey(value?.toString());
      }
    });

    return StudentMonthlyAttendanceModel(
      id: docId ?? json['id'] ?? '',
      studentId: studentId ?? json['studentId'] ?? '',
      year: json['year'] ?? DateTime.now().year,
      month: json['month'] ?? DateTime.now().month,
      days: parsedDays,
    );
  }

  Map<String, dynamic> toJson() {
    final dayMap = <String, String>{};
    days.forEach((day, status) {
      if (status != AttendanceDayStatus.unmarked) {
        dayMap[day.toString()] = status.firestoreKey;
      }
    });
    return {
      'id': id,
      'studentId': studentId,
      'year': year,
      'month': month,
      'days': dayMap,
    };
  }

  static String monthDocId(int year, int month) =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
}
