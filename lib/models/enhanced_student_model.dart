// lib/models/enhanced_student_model.dart
// Complete student profile for the management system

enum StudentGender { male, female, other }
enum BloodGroup { aPos, aNeg, bPos, bNeg, abPos, abNeg, oPos, oNeg }
enum StudentCategory { general, obc, sc, st, minority }
enum AdmissionStatus { active, transferred, dropout, passed }

extension BloodGroupExt on BloodGroup {
  String get label {
    switch (this) {
      case BloodGroup.aPos: return 'A+';
      case BloodGroup.aNeg: return 'A-';
      case BloodGroup.bPos: return 'B+';
      case BloodGroup.bNeg: return 'B-';
      case BloodGroup.abPos: return 'AB+';
      case BloodGroup.abNeg: return 'AB-';
      case BloodGroup.oPos: return 'O+';
      case BloodGroup.oNeg: return 'O-';
    }
  }
}

class EnhancedStudentModel {
  // ── Identity ─────────────────────────────────────────────────────────────
  final String id;
  final String apaarId;
  final String admissionNumber;
  final String rollNumber;
  final String name;
  final DateTime dateOfBirth;
  final StudentGender gender;
  final BloodGroup? bloodGroup;
  final String? photoUrl;
  final AdmissionStatus status;

  // ── Academic ─────────────────────────────────────────────────────────────
  final int grade;
  final String section;
  final String schoolUdise;
  final DateTime admissionDate;
  final String? previousSchool;
  final StudentCategory category;
  final double attendancePercentage;

  // ── Family ───────────────────────────────────────────────────────────────
  final String fatherName;
  final String motherName;
  final String? guardianName;
  final String? parentOccupation;
  final double? annualIncome;

  // ── Contact ──────────────────────────────────────────────────────────────
  final String phone;
  final String? emergencyPhone;
  final String? email;
  final String? address;
  final String? pincode;

  // ── Health ───────────────────────────────────────────────────────────────
  final double? heightCm;
  final double? weightKg;
  final String? medicalConditions;
  final String? disability;

  EnhancedStudentModel({
    required this.id,
    required this.apaarId,
    this.admissionNumber = '',
    this.rollNumber = '',
    required this.name,
    required this.dateOfBirth,
    this.gender = StudentGender.male,
    this.bloodGroup,
    this.photoUrl,
    this.status = AdmissionStatus.active,
    required this.grade,
    this.section = 'A',
    required this.schoolUdise,
    required this.admissionDate,
    this.previousSchool,
    this.category = StudentCategory.general,
    this.attendancePercentage = 0.0,
    this.fatherName = '',
    this.motherName = '',
    this.guardianName,
    this.parentOccupation,
    this.annualIncome,
    this.phone = '',
    this.emergencyPhone,
    this.email,
    this.address,
    this.pincode,
    this.heightCm,
    this.weightKg,
    this.medicalConditions,
    this.disability,
  });

  int get age {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  double? get bmi {
    if (heightCm == null || weightKg == null || heightCm! <= 0) return null;
    final hM = heightCm! / 100;
    return weightKg! / (hM * hM);
  }

  factory EnhancedStudentModel.fromJson(Map<String, dynamic> json,
      {String? docId}) {
    return EnhancedStudentModel(
      id: docId ?? json['id'] ?? '',
      apaarId: json['apaarId'] ?? '',
      admissionNumber: json['admissionNumber'] ?? '',
      rollNumber: json['rollNumber'] ?? '',
      name: json['name'] ?? '',
      dateOfBirth: DateTime.tryParse(json['dateOfBirth'] ?? '') ?? DateTime(2010),
      gender: StudentGender.values.firstWhere(
          (e) => e.name == json['gender'], orElse: () => StudentGender.male),
      bloodGroup: json['bloodGroup'] != null
          ? BloodGroup.values.firstWhere((e) => e.name == json['bloodGroup'],
              orElse: () => BloodGroup.oPos)
          : null,
      photoUrl: json['photoUrl'],
      status: AdmissionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => AdmissionStatus.active),
      grade: json['grade'] ?? 0,
      section: json['section'] ?? 'A',
      schoolUdise: json['schoolUdise'] ?? json['enrolledSchoolUdise'] ?? '',
      admissionDate:
          DateTime.tryParse(json['admissionDate'] ?? '') ?? DateTime.now(),
      previousSchool: json['previousSchool'],
      category: StudentCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => StudentCategory.general),
      attendancePercentage:
          (json['attendancePercentage'] ?? 0.0).toDouble(),
      fatherName: json['fatherName'] ?? '',
      motherName: json['motherName'] ?? '',
      guardianName: json['guardianName'],
      parentOccupation: json['parentOccupation'],
      annualIncome: (json['annualIncome'] as num?)?.toDouble(),
      phone: json['phone'] ?? '',
      emergencyPhone: json['emergencyPhone'],
      email: json['email'],
      address: json['address'],
      pincode: json['pincode'],
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      medicalConditions: json['medicalConditions'],
      disability: json['disability'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'apaarId': apaarId,
        'admissionNumber': admissionNumber,
        'rollNumber': rollNumber,
        'name': name,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'gender': gender.name,
        'bloodGroup': bloodGroup?.name,
        'photoUrl': photoUrl,
        'status': status.name,
        'grade': grade,
        'section': section,
        'schoolUdise': schoolUdise,
        'enrolledSchoolUdise': schoolUdise,
        'admissionDate': admissionDate.toIso8601String(),
        'previousSchool': previousSchool,
        'category': category.name,
        'attendancePercentage': attendancePercentage,
        'fatherName': fatherName,
        'motherName': motherName,
        'guardianName': guardianName,
        'parentOccupation': parentOccupation,
        'annualIncome': annualIncome,
        'phone': phone,
        'emergencyPhone': emergencyPhone,
        'email': email,
        'address': address,
        'pincode': pincode,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'medicalConditions': medicalConditions,
        'disability': disability,
      };
}
