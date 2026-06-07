enum ExamType {
  unitTest1,
  unitTest2,
  halfYearly,
  annual,
}

extension ExamTypeX on ExamType {
  String get label {
    switch (this) {
      case ExamType.unitTest1:
        return 'Unit Test 1';
      case ExamType.unitTest2:
        return 'Unit Test 2';
      case ExamType.halfYearly:
        return 'Half Yearly';
      case ExamType.annual:
        return 'Annual';
    }
  }

  String get firestoreKey => name;

  static ExamType fromKey(String key) {
    return ExamType.values.firstWhere(
      (e) => e.name == key,
      orElse: () => ExamType.unitTest1,
    );
  }
}

class ExamModel {
  final String id;
  final String studentId;
  final ExamType type;
  final int year;
  final String name;
  final int sortOrder;

  ExamModel({
    required this.id,
    required this.studentId,
    required this.type,
    required this.year,
    required this.name,
    required this.sortOrder,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json, {String? studentId}) {
    return ExamModel(
      id: json['id'] ?? '',
      studentId: studentId ?? json['studentId'] ?? '',
      type: ExamTypeX.fromKey(json['type'] ?? 'unitTest1'),
      year: json['year'] ?? DateTime.now().year,
      name: json['name'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'type': type.firestoreKey,
        'year': year,
        'name': name,
        'sortOrder': sortOrder,
      };
}
