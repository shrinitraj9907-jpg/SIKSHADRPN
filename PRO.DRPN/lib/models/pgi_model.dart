class PgiScoreModel {
  final String districtId;
  final String stateId;
  final int year;
  final double learningOutcomes; // Out of 180
  final double access; // Out of 80
  final double infrastructure; // Out of 150
  final double equity; // Out of 230
  final double governanceProcess; // Out of 360

  PgiScoreModel({
    required this.districtId,
    required this.stateId,
    required this.year,
    required this.learningOutcomes,
    required this.access,
    required this.infrastructure,
    required this.equity,
    required this.governanceProcess,
  });

  double get totalScore =>
      learningOutcomes + access + infrastructure + equity + governanceProcess;

  String get grade {
    if (totalScore > 950) return 'Daksh';
    if (totalScore > 900) return 'Utkarsh';
    if (totalScore > 850) return 'Ati-Uttam';
    if (totalScore > 800) return 'Uttam';
    if (totalScore > 750) return 'Prachesta-1';
    if (totalScore > 700) return 'Prachesta-2';
    if (totalScore > 650) return 'Prachesta-3';
    return 'Akanshi'; // Needs maximum improvement
  }

  factory PgiScoreModel.fromJson(Map<String, dynamic> json) {
    return PgiScoreModel(
      districtId: json['districtId'],
      stateId: json['stateId'],
      year: json['year'],
      learningOutcomes: json['learningOutcomes']?.toDouble() ?? 0.0,
      access: json['access']?.toDouble() ?? 0.0,
      infrastructure: json['infrastructure']?.toDouble() ?? 0.0,
      equity: json['equity']?.toDouble() ?? 0.0,
      governanceProcess: json['governanceProcess']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'districtId': districtId,
      'stateId': stateId,
      'year': year,
      'learningOutcomes': learningOutcomes,
      'access': access,
      'infrastructure': infrastructure,
      'equity': equity,
      'governanceProcess': governanceProcess,
    };
  }
}
