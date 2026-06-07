import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shiksha_darpan/models/user_model.dart';
import 'package:shiksha_darpan/screens/attendance/teacher_checkin_screen.dart';
import 'package:shiksha_darpan/screens/attendance/teacher_ratings_screen.dart';
import 'package:shiksha_darpan/screens/auth/login_screen.dart';
import 'package:shiksha_darpan/screens/student/teacher_student_hub_screen.dart';
import 'package:shiksha_darpan/services/auth_service.dart';
import 'package:shiksha_darpan/services/database_service.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({Key? key}) : super(key: key);

  @override
  _TeacherDashboardScreenState createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _currentIndex = 0;
  UserModel? _teacherProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final profile = await DatabaseService().getUserProfile(uid);
    if (mounted) setState(() => _teacherProfile = profile);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const TeacherCheckinScreen(),
      TeacherStudentHubScreen(teacher: _teacherProfile),
      const TeacherRatingsScreen(),
    ];

    return Scaffold(
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              title: Text(
                _currentIndex == 1 ? 'Student Panel' : 'My Ratings',
              ),
              backgroundColor: Colors.indigo,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                  onPressed: () async {
                    await AuthService().signOut();
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Check-in',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            selectedIcon: Icon(Icons.star),
            label: 'Ratings',
          ),
        ],
      ),
    );
  }
}
