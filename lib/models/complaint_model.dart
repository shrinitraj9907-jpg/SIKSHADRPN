import 'package:shiksha_darpan/models/user_model.dart';

enum ComplaintStatus {
  open,
  inProgress,
  resolved,
  escalated,
}

class ComplaintModel {
  final String id;
  final String schoolUdiseCode;
  final String title;
  final String description;
  final bool isAnonymous;
  final String? submitterId; // Null if anonymous
  final DateTime submittedDate;
  
  // The current level managing this complaint
  // e.g., If unresolved at Ground for 7 days, moves to Intermediate
  AdministrativeLevel currentEscalationLevel; 
  ComplaintStatus status;
  final List<String> evidencePhotoUrls;

  ComplaintModel({
    required this.id,
    required this.schoolUdiseCode,
    required this.title,
    required this.description,
    required this.isAnonymous,
    this.submitterId,
    required this.submittedDate,
    required this.currentEscalationLevel,
    this.status = ComplaintStatus.open,
    this.evidencePhotoUrls = const [],
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'],
      schoolUdiseCode: json['schoolUdiseCode'],
      title: json['title'],
      description: json['description'],
      isAnonymous: json['isAnonymous'] ?? false,
      submitterId: json['submitterId'],
      submittedDate: DateTime.parse(json['submittedDate']),
      currentEscalationLevel: AdministrativeLevel.values.firstWhere(
        (e) => e.toString() == 'AdministrativeLevel.${json['currentEscalationLevel']}',
      ),
      status: ComplaintStatus.values.firstWhere(
        (e) => e.toString() == 'ComplaintStatus.${json['status']}',
        orElse: () => ComplaintStatus.open,
      ),
      evidencePhotoUrls: List<String>.from(json['evidencePhotoUrls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolUdiseCode': schoolUdiseCode,
      'title': title,
      'description': description,
      'isAnonymous': isAnonymous,
      'submitterId': submitterId,
      'submittedDate': submittedDate.toIso8601String(),
      'currentEscalationLevel': currentEscalationLevel.toString().split('.').last,
      'status': status.toString().split('.').last,
      'evidencePhotoUrls': evidencePhotoUrls,
    };
  }
}
