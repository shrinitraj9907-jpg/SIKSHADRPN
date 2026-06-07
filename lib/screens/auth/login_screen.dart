import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shiksha_darpan/screens/attendance/teacher_dashboard_screen.dart';
import 'package:shiksha_darpan/screens/dashboard/district_dashboard_screen.dart';
import 'package:shiksha_darpan/screens/dashboard/state_dashboard_screen.dart';
import 'package:shiksha_darpan/screens/dashboard/national_dashboard_screen.dart';
import 'package:shiksha_darpan/screens/dashboard/principal_dashboard_screen.dart';
import 'package:shiksha_darpan/models/user_model.dart';
import 'package:shiksha_darpan/main.dart';
import 'package:shiksha_darpan/services/auth_service.dart';
import 'package:shiksha_darpan/screens/student/student_panel_screen.dart';
import 'package:shiksha_darpan/services/database_service.dart';
import 'package:shiksha_darpan/services/student_panel_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _selectedRole = UserRole.teacher;
  final TextEditingController _emailController = TextEditingController();

  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  AdministrativeLevel _getLevelForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
      case UserRole.parent:
        return AdministrativeLevel.ground;
      case UserRole.supportStaff:
      case UserRole.teacher:
      case UserRole.principal:
      case UserRole.smcMember:
        return AdministrativeLevel.ground;
      case UserRole.crcc:
      case UserRole.brcc:
      case UserRole.deo:
        return AdministrativeLevel.intermediate;
      case UserRole.dpi:
      case UserRole.secretaryEducation:
      case UserRole.stateMinister:
        return AdministrativeLevel.state;
      case UserRole.sectionOfficer:
      case UserRole.jointSecretary:
      case UserRole.secretaryMoE:
      case UserRole.unionMinister:
        return AdministrativeLevel.national;
    }
  }

  void _routeUserByRoleAndLevel(
    UserRole role,
    AdministrativeLevel level, {
    UserModel? profile,
  }) {
    Widget destination;

    if (role == UserRole.student || role == UserRole.parent) {
      final studentId = profile?.linkedStudentId ?? 'demo_student_001';
      StudentPanelService().seedDemoStudentData(studentId);
      destination = StudentPanelScreen(studentId: studentId);
    } else if (role == UserRole.principal) {
      destination = const PrincipalDashboardScreen();
    } else {
      switch (level) {
        case AdministrativeLevel.ground:
          destination = const TeacherDashboardScreen();
          break;
        case AdministrativeLevel.intermediate:
          destination = const DistrictDashboardScreen();
          break;
        case AdministrativeLevel.state:
          destination = const StateDashboardScreen();
          break;
        case AdministrativeLevel.national:
          destination = const NationalDashboardScreen();
          break;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid Gmail / Email Address to continue.',
          ),
        ),
      );
      return;
    }

    final level = _getLevelForRole(_selectedRole);
    if (_selectedRole == UserRole.student ||
        _selectedRole == UserRole.parent) {
      StudentPanelService().seedDemoStudentData('demo_student_001');
    }
    _routeUserByRoleAndLevel(_selectedRole, level);
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final userCred = await _authService.signInWithGoogle();
      if (userCred == null || userCred.user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final user = userCred.user!;
      UserModel? profile = await _dbService.getUserProfile(user.uid);

      if (!mounted) return;

      if (profile == null) {
        _showRoleSelectionBottomSheet(user);
      } else {
        _routeUserByRoleAndLevel(
          profile.role,
          profile.level,
          profile: profile,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Authentication Failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRoleSelectionBottomSheet(User firebaseUser) {
    UserRole tempRole = UserRole.teacher;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.badge, color: Colors.blue[900], size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Set Up Your Profile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select your designated role to customize your ShikshaDarpan portal experience.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Select Role:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<UserRole>(
                        isExpanded: true,
                        value: tempRole,
                        items: UserRole.values.map((role) {
                          String roleText = role.toString().split('.').last;
                          roleText =
                              roleText[0].toUpperCase() + roleText.substring(1);
                          return DropdownMenuItem(
                            value: role,
                            child: Text(
                              roleText,
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              tempRole = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        setState(() => _isLoading = true);
                        try {
                          final newProfile = UserModel(
                            id: firebaseUser.uid,
                            name: firebaseUser.displayName ??
                                firebaseUser.email?.split('@').first ??
                                'User',
                            role: tempRole,
                            level: _getLevelForRole(tempRole),
                            email: firebaseUser.email ?? '',
                            phone: firebaseUser.phoneNumber ?? '',
                            linkedStudentId:
                                (tempRole == UserRole.student ||
                                        tempRole == UserRole.parent)
                                    ? 'demo_student_001'
                                    : null,
                            assignedSubjects:
                                tempRole == UserRole.teacher
                                    ? const [
                                        'Mathematics',
                                        'Science',
                                        'English',
                                      ]
                                    : const [],
                          );

                          await _dbService.createUserProfile(newProfile);

                          if (!mounted) return;
                          _routeUserByRoleAndLevel(
                            newProfile.role,
                            newProfile.level,
                            profile: newProfile,
                          );
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save profile: $e'),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Complete Setup & Login',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance,
                        size: 64,
                        color: Colors.blue[900],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'ShikshaDarpan',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'National Education Monitoring',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Gmail / Email Address',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Select Role for Demo Routing:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<UserRole>(
                            isExpanded: true,
                            value: _selectedRole,
                            items: UserRole.values.map((role) {
                              String roleText = role.toString().split('.').last;
                              roleText = roleText[0].toUpperCase() +
                                  roleText.substring(1);
                              return DropdownMenuItem(
                                value: role,
                                child: Text(roleText),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedRole = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              'OR',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          icon: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                            height: 24,
                          ),
                          label: const Text(
                            'Sign in with Google',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(
                themeNotifier.value == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode,
                size: 30,
              ),
              onPressed: () {
                setState(() {
                  themeNotifier.value = themeNotifier.value == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light;
                });
              },
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
