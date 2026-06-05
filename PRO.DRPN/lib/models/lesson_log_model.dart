class LessonLogModel {
  final String id;
  final String teacherId;
  final String subject;
  final String topic;
  final int completionPercentage;
  final DateTime date;

  LessonLogModel({
    required this.id,
    required this.teacherId,
    required this.subject,
    required this.topic,
    required this.completionPercentage,
    required this.date,
  });

  factory LessonLogModel.fromJson(Map<String, dynamic> json) {
    return LessonLogModel(
      id: json['id'],
      teacherId: json['teacherId'],
      subject: json['subject'],
      topic: json['topic'],
      completionPercentage: json['completionPercentage'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
      'subject': subject,
      'topic': topic,
      'completionPercentage': completionPercentage,
      'date': date.toIso8601String(),
    };
  }
}
