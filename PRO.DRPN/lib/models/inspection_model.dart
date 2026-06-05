class InspectionModel {
  final String id;
  final String schoolUdiseCode;
  final String inspectorId; // User ID of the CRCC, BEO, or DEO
  final DateTime inspectionDate;
  final bool infrastructureVerified;
  final bool pedagogicalStandardsMet;
  final String remarks;
  final List<String> photoUrls;

  InspectionModel({
    required this.id,
    required this.schoolUdiseCode,
    required this.inspectorId,
    required this.inspectionDate,
    required this.infrastructureVerified,
    required this.pedagogicalStandardsMet,
    required this.remarks,
    this.photoUrls = const [],
  });

  factory InspectionModel.fromJson(Map<String, dynamic> json) {
    return InspectionModel(
      id: json['id'],
      schoolUdiseCode: json['schoolUdiseCode'],
      inspectorId: json['inspectorId'],
      inspectionDate: DateTime.parse(json['inspectionDate']),
      infrastructureVerified: json['infrastructureVerified'] ?? false,
      pedagogicalStandardsMet: json['pedagogicalStandardsMet'] ?? false,
      remarks: json['remarks'] ?? '',
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolUdiseCode': schoolUdiseCode,
      'inspectorId': inspectorId,
      'inspectionDate': inspectionDate.toIso8601String(),
      'infrastructureVerified': infrastructureVerified,
      'pedagogicalStandardsMet': pedagogicalStandardsMet,
      'remarks': remarks,
      'photoUrls': photoUrls,
    };
  }
}
