class NationalBudgetModel {
  final String fiscalYear;
  final double totalAllocation; // in Crores
  final double utilizedAmount; // in Crores
  final double infrastructureSpend;
  final double teacherTrainingSpend;
  final double digitalInitiativesSpend;

  NationalBudgetModel({
    required this.fiscalYear,
    required this.totalAllocation,
    required this.utilizedAmount,
    required this.infrastructureSpend,
    required this.teacherTrainingSpend,
    required this.digitalInitiativesSpend,
  });

  double get utilizationPercentage => (utilizedAmount / totalAllocation) * 100;

  factory NationalBudgetModel.fromJson(Map<String, dynamic> json) {
    return NationalBudgetModel(
      fiscalYear: json['fiscalYear'],
      totalAllocation: json['totalAllocation']?.toDouble() ?? 0.0,
      utilizedAmount: json['utilizedAmount']?.toDouble() ?? 0.0,
      infrastructureSpend: json['infrastructureSpend']?.toDouble() ?? 0.0,
      teacherTrainingSpend: json['teacherTrainingSpend']?.toDouble() ?? 0.0,
      digitalInitiativesSpend: json['digitalInitiativesSpend']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fiscalYear': fiscalYear,
      'totalAllocation': totalAllocation,
      'utilizedAmount': utilizedAmount,
      'infrastructureSpend': infrastructureSpend,
      'teacherTrainingSpend': teacherTrainingSpend,
      'digitalInitiativesSpend': digitalInitiativesSpend,
    };
  }
}
