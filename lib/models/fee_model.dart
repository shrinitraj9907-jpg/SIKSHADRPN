// lib/models/fee_model.dart

enum FeeType { tuition, transport, library, sports, examination, miscellaneous }
enum FeeStatus { paid, pending, partial, waived }

class FeeStructureModel {
  final String id;
  final int grade;
  final String schoolUdise;
  final int academicYear;
  final Map<FeeType, double> feeComponents; // component → amount

  FeeStructureModel({
    required this.id,
    required this.grade,
    required this.schoolUdise,
    required this.academicYear,
    required this.feeComponents,
  });

  double get totalFee => feeComponents.values.fold(0, (a, b) => a + b);

  factory FeeStructureModel.fromJson(Map<String, dynamic> json,
      {String? docId}) {
    final components = <FeeType, double>{};
    final raw = json['feeComponents'] as Map<String, dynamic>? ?? {};
    for (final entry in raw.entries) {
      final type = FeeType.values.firstWhere((e) => e.name == entry.key,
          orElse: () => FeeType.miscellaneous);
      components[type] = (entry.value as num).toDouble();
    }
    return FeeStructureModel(
      id: docId ?? json['id'] ?? '',
      grade: json['grade'] ?? 0,
      schoolUdise: json['schoolUdise'] ?? '',
      academicYear: json['academicYear'] ?? DateTime.now().year,
      feeComponents: components,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'grade': grade,
        'schoolUdise': schoolUdise,
        'academicYear': academicYear,
        'feeComponents': feeComponents.map((k, v) => MapEntry(k.name, v)),
      };
}

class FeePaymentModel {
  final String id;
  final String studentId;
  final String studentName;
  final int academicYear;
  final String schoolUdise;
  final double totalAmount;
  final double paidAmount;
  final FeeStatus status;
  final DateTime? paidDate;
  final String? receiptNumber;
  final String? remarks;
  final double? scholarshipAmount;
  final String? scholarshipScheme;

  FeePaymentModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.academicYear,
    required this.schoolUdise,
    required this.totalAmount,
    this.paidAmount = 0,
    this.status = FeeStatus.pending,
    this.paidDate,
    this.receiptNumber,
    this.remarks,
    this.scholarshipAmount,
    this.scholarshipScheme,
  });

  double get dueAmount => (totalAmount - (scholarshipAmount ?? 0)) - paidAmount;

  factory FeePaymentModel.fromJson(Map<String, dynamic> json,
      {String? docId}) {
    return FeePaymentModel(
      id: docId ?? json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      academicYear: json['academicYear'] ?? DateTime.now().year,
      schoolUdise: json['schoolUdise'] ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      status: FeeStatus.values.firstWhere((e) => e.name == json['status'],
          orElse: () => FeeStatus.pending),
      paidDate: json['paidDate'] != null
          ? DateTime.tryParse(json['paidDate'])
          : null,
      receiptNumber: json['receiptNumber'],
      remarks: json['remarks'],
      scholarshipAmount: (json['scholarshipAmount'] as num?)?.toDouble(),
      scholarshipScheme: json['scholarshipScheme'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'studentName': studentName,
        'academicYear': academicYear,
        'schoolUdise': schoolUdise,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'status': status.name,
        'paidDate': paidDate?.toIso8601String(),
        'receiptNumber': receiptNumber,
        'remarks': remarks,
        'scholarshipAmount': scholarshipAmount,
        'scholarshipScheme': scholarshipScheme,
      };
}
