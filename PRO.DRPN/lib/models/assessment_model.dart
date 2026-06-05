enum AssessmentType {
  nas,          // National Achievement Survey
  parakh,       // Performance Assessment, Review, and Analysis of Knowledge for Holistic Development
  nipunBharat,  // Foundational Literacy and Numeracy
  formative,    // Regular school-level tests
}

class AssessmentModel {
  final String id;
  final String studentApaarId;
  final AssessmentType type;
  final DateTime assessmentDate;
  final Map<String, dynamic> scores; // e.g., {'math': 85, 'reading': 90}
  final bool meetsNipunStandard; // Specifically for foundational literacy/numeracy tracking

  AssessmentModel({
    required this.id,
    required this.studentApaarId,
    required this.type,
    required this.assessmentDate,
    required this.scores,
    this.meetsNipunStandard = false,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['id'],
      studentApaarId: json['studentApaarId'],
      type: AssessmentType.values.firstWhere((e) => e.toString() == 'AssessmentType.${json['type']}'),
      assessmentDate: DateTime.parse(json['assessmentDate']),
      scores: Map<String, dynamic>.from(json['scores']),
      meetsNipunStandard: json['meetsNipunStandard'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentApaarId': studentApaarId,
      'type': type.toString().split('.').last,
      'assessmentDate': assessmentDate.toIso8601String(),
      'scores': scores,
      'meetsNipunStandard': meetsNipunStandard,
    };
  }
}
