class TeacherRatingModel {
  final String id;
  final String teacherId;
  final String schoolUdiseCode;
  final int qualityScore;
  final int punctualityScore;
  final int fairnessScore;
  final String? comments;
  final DateTime date;

  TeacherRatingModel({
    required this.id,
    required this.teacherId,
    required this.schoolUdiseCode,
    required this.qualityScore,
    required this.punctualityScore,
    required this.fairnessScore,
    this.comments,
    required this.date,
  });

  // Calculate the average out of 100 for the ShameBoard/Transparency score
  double get totalScore => ((qualityScore + punctualityScore + fairnessScore) / 15) * 100;

  factory TeacherRatingModel.fromJson(Map<String, dynamic> json) {
    return TeacherRatingModel(
      id: json['id'],
      teacherId: json['teacherId'],
      schoolUdiseCode: json['schoolUdiseCode'],
      qualityScore: json['qualityScore'],
      punctualityScore: json['punctualityScore'],
      fairnessScore: json['fairnessScore'],
      comments: json['comments'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
      'schoolUdiseCode': schoolUdiseCode,
      'qualityScore': qualityScore,
      'punctualityScore': punctualityScore,
      'fairnessScore': fairnessScore,
      'comments': comments,
      'date': date.toIso8601String(),
    };
  }
}
