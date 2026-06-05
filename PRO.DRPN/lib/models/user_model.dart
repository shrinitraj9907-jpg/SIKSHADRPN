enum AdministrativeLevel {
  ground,       // Level 1: School & Community
  intermediate, // Level 2: Block & District
  state,        // Level 3: State Executive
  national,     // Level 4: National Policy & Oversight
}

enum UserRole {
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
  final String? assignedJurisdictionId; // School ID / District ID / State ID
  final String email;
  final String phone;
  final String? googleId;       // Firebase UID (also the Firestore doc ID)
  final String? profilePicture; // Google profile photo URL

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.level,
    this.assignedJurisdictionId,
    required this.email,
    this.phone = '',
    this.googleId,
    this.profilePicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.teacher,
      ),
      level: AdministrativeLevel.values.firstWhere(
        (e) => e.toString() == 'AdministrativeLevel.${json['level']}',
        orElse: () => AdministrativeLevel.ground,
      ),
      assignedJurisdictionId: json['assignedJurisdictionId'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      googleId: json['googleId'],
      profilePicture: json['profilePicture'],
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
      'googleId': googleId,
      'profilePicture': profilePicture,
    };
  }

  /// Returns a copy of this model with updated fields.
  UserModel copyWith({
    String? id,
    String? name,
    UserRole? role,
    AdministrativeLevel? level,
    String? assignedJurisdictionId,
    String? email,
    String? phone,
    String? googleId,
    String? profilePicture,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      level: level ?? this.level,
      assignedJurisdictionId: assignedJurisdictionId ?? this.assignedJurisdictionId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      googleId: googleId ?? this.googleId,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
