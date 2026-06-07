// lib/models/health_model.dart

enum HealthCheckupType { annual, vision, dental, bmi, general }
enum VaccinationType { bcg, hepatitisB, dpt, mmr, polio, typhoid, covid, other }

class HealthRecordModel {
  final String id;
  final String studentId;
  final HealthCheckupType checkupType;
  final DateTime checkupDate;
  final double? heightCm;
  final double? weightKg;
  final String? visionLeft;
  final String? visionRight;
  final String? dentalStatus;
  final String? bloodPressure;
  final String? hemoglobin;
  final String? remarks;
  final String? doctorName;
  final bool? referredForTreatment;

  HealthRecordModel({
    required this.id,
    required this.studentId,
    required this.checkupType,
    required this.checkupDate,
    this.heightCm,
    this.weightKg,
    this.visionLeft,
    this.visionRight,
    this.dentalStatus,
    this.bloodPressure,
    this.hemoglobin,
    this.remarks,
    this.doctorName,
    this.referredForTreatment,
  });

  double? get bmi {
    if (heightCm == null || weightKg == null || heightCm! <= 0) return null;
    final hM = heightCm! / 100;
    return weightKg! / (hM * hM);
  }

  String get bmiCategory {
    final b = bmi;
    if (b == null) return 'N/A';
    if (b < 18.5) return 'Underweight';
    if (b < 25) return 'Normal';
    if (b < 30) return 'Overweight';
    return 'Obese';
  }

  factory HealthRecordModel.fromJson(Map<String, dynamic> json,
      {String? docId}) {
    return HealthRecordModel(
      id: docId ?? json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      checkupType: HealthCheckupType.values.firstWhere(
          (e) => e.name == json['checkupType'],
          orElse: () => HealthCheckupType.general),
      checkupDate:
          DateTime.tryParse(json['checkupDate'] ?? '') ?? DateTime.now(),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      visionLeft: json['visionLeft'],
      visionRight: json['visionRight'],
      dentalStatus: json['dentalStatus'],
      bloodPressure: json['bloodPressure'],
      hemoglobin: json['hemoglobin'],
      remarks: json['remarks'],
      doctorName: json['doctorName'],
      referredForTreatment: json['referredForTreatment'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'checkupType': checkupType.name,
        'checkupDate': checkupDate.toIso8601String(),
        'heightCm': heightCm,
        'weightKg': weightKg,
        'visionLeft': visionLeft,
        'visionRight': visionRight,
        'dentalStatus': dentalStatus,
        'bloodPressure': bloodPressure,
        'hemoglobin': hemoglobin,
        'remarks': remarks,
        'doctorName': doctorName,
        'referredForTreatment': referredForTreatment,
      };
}

class VaccinationRecordModel {
  final String id;
  final String studentId;
  final VaccinationType vaccinationType;
  final String vaccineName;
  final DateTime givenDate;
  final DateTime? nextDoseDate;
  final String? givenBy;
  final String? batchNumber;

  VaccinationRecordModel({
    required this.id,
    required this.studentId,
    required this.vaccinationType,
    required this.vaccineName,
    required this.givenDate,
    this.nextDoseDate,
    this.givenBy,
    this.batchNumber,
  });

  factory VaccinationRecordModel.fromJson(Map<String, dynamic> json,
      {String? docId}) {
    return VaccinationRecordModel(
      id: docId ?? json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      vaccinationType: VaccinationType.values.firstWhere(
          (e) => e.name == json['vaccinationType'],
          orElse: () => VaccinationType.other),
      vaccineName: json['vaccineName'] ?? '',
      givenDate:
          DateTime.tryParse(json['givenDate'] ?? '') ?? DateTime.now(),
      nextDoseDate: json['nextDoseDate'] != null
          ? DateTime.tryParse(json['nextDoseDate'])
          : null,
      givenBy: json['givenBy'],
      batchNumber: json['batchNumber'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'vaccinationType': vaccinationType.name,
        'vaccineName': vaccineName,
        'givenDate': givenDate.toIso8601String(),
        'nextDoseDate': nextDoseDate?.toIso8601String(),
        'givenBy': givenBy,
        'batchNumber': batchNumber,
      };
}
