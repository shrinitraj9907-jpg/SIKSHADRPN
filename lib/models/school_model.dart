class InfrastructureMetrics {
  final int totalToilets;
  final int functionalToilets;
  final bool hasLibrary;
  final bool hasComputerLab;
  final int functionalComputers;

  InfrastructureMetrics({
    required this.totalToilets,
    required this.functionalToilets,
    required this.hasLibrary,
    required this.hasComputerLab,
    required this.functionalComputers,
  });

  factory InfrastructureMetrics.fromJson(Map<String, dynamic> json) {
    return InfrastructureMetrics(
      totalToilets: json['totalToilets'] ?? 0,
      functionalToilets: json['functionalToilets'] ?? 0,
      hasLibrary: json['hasLibrary'] ?? false,
      hasComputerLab: json['hasComputerLab'] ?? false,
      functionalComputers: json['functionalComputers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalToilets': totalToilets,
      'functionalToilets': functionalToilets,
      'hasLibrary': hasLibrary,
      'hasComputerLab': hasComputerLab,
      'functionalComputers': functionalComputers,
    };
  }
}

class SchoolModel {
  final String udiseCode; // Unique UDISE+ identifier
  final String name;
  final String district;
  final String state;
  final String cluster;
  final InfrastructureMetrics infrastructure;
  final int totalStudents;
  final int totalTeachers;

  SchoolModel({
    required this.udiseCode,
    required this.name,
    required this.district,
    required this.state,
    required this.cluster,
    required this.infrastructure,
    required this.totalStudents,
    required this.totalTeachers,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      udiseCode: json['udiseCode'],
      name: json['name'],
      district: json['district'],
      state: json['state'],
      cluster: json['cluster'],
      infrastructure: InfrastructureMetrics.fromJson(json['infrastructure']),
      totalStudents: json['totalStudents'] ?? 0,
      totalTeachers: json['totalTeachers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'udiseCode': udiseCode,
      'name': name,
      'district': district,
      'state': state,
      'cluster': cluster,
      'infrastructure': infrastructure.toJson(),
      'totalStudents': totalStudents,
      'totalTeachers': totalTeachers,
    };
  }
}
