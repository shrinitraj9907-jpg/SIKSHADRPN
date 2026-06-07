enum AdministrativeLevel {
  ground,       // Level 1: School & Community
  intermediate, // Level 2: Block & District
  state,        // Level 3: State Executive
  national,     // Level 4: National Policy & Oversight
}

enum UserRole {
  // Student / Parent
  student,
  parent,

  // Ground Level
  supportStaff,
  teacher,
  principal,
  smcMember,

  // Intermediate Level
  crcc,
  brcc,
  deo,

  // State Level
  dpi,
  secretaryEducation,
  stateMinister,

  // National Level
  sectionOfficer,
  jointSecretary,
  secretaryMoE,
  unionMinister,
}

class UserModel {
  final String id;
  final String name;
  final UserRole role;
  final AdministrativeLevel level;
  final String? assignedJurisdictionId;
  final String email;
  final String phone;
  final String? linkedStudentId;
  final List<String> assignedSubjects;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.level,
    this.assignedJurisdictionId,
    required this.email,
    required this.phone,
    this.linkedStudentId,
    this.assignedSubjects = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
      ),
      level: AdministrativeLevel.values.firstWhere(
        (e) => e.toString() == 'AdministrativeLevel.${json['level']}',
      ),
      assignedJurisdictionId: json['assignedJurisdictionId'],
      email: json['email'],
      phone: json['phone'],
      linkedStudentId: json['linkedStudentId'],
      assignedSubjects: (json['assignedSubjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.toString().split('.').last,
      'level': level.toString().split('.').last,
      'assignedJurisdictionId': assignedJurisdictionId,
      'email': email,
      'phone': phone,
      'linkedStudentId': linkedStudentId,
      'assignedSubjects': assignedSubjects,
    };
  }

  bool get isStudentOrParent =>
      role == UserRole.student || role == UserRole.parent;

  bool canEditSubject(String subjectKey) =>
      role == UserRole.principal ||
      (role == UserRole.teacher &&
          assignedSubjects
              .map((s) => s.toLowerCase())
              .contains(subjectKey.toLowerCase()));
}
