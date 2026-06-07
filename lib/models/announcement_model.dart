// lib/models/announcement_model.dart

enum AnnouncementPriority { low, normal, high, urgent }
enum AnnouncementAudience { all, teachers, parents, students, class_specific }

class AnnouncementModel {
  final String id;
  final String schoolUdise;
  final String title;
  final String body;
  final AnnouncementPriority priority;
  final AnnouncementAudience audience;
  final String? targetGrade;
  final String? targetSection;
  final DateTime createdAt;
  final String createdByName;
  final String createdById;
  final String? attachmentUrl;
  final DateTime? expiresAt;

  AnnouncementModel({
    required this.id,
    required this.schoolUdise,
    required this.title,
    required this.body,
    this.priority = AnnouncementPriority.normal,
    this.audience = AnnouncementAudience.all,
    this.targetGrade,
    this.targetSection,
    required this.createdAt,
    required this.createdByName,
    required this.createdById,
    this.attachmentUrl,
    this.expiresAt,
  });

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  factory AnnouncementModel.fromJson(Map<String, dynamic> json,
      {String? docId}) {
    return AnnouncementModel(
      id: docId ?? json['id'] ?? '',
      schoolUdise: json['schoolUdise'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      priority: AnnouncementPriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => AnnouncementPriority.normal),
      audience: AnnouncementAudience.values.firstWhere(
          (e) => e.name == json['audience'],
          orElse: () => AnnouncementAudience.all),
      targetGrade: json['targetGrade'],
      targetSection: json['targetSection'],
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      createdByName: json['createdByName'] ?? '',
      createdById: json['createdById'] ?? '',
      attachmentUrl: json['attachmentUrl'],
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'schoolUdise': schoolUdise,
        'title': title,
        'body': body,
        'priority': priority.name,
        'audience': audience.name,
        'targetGrade': targetGrade,
        'targetSection': targetSection,
        'createdAt': createdAt.toIso8601String(),
        'createdByName': createdByName,
        'createdById': createdById,
        'attachmentUrl': attachmentUrl,
        'expiresAt': expiresAt?.toIso8601String(),
      };
}
