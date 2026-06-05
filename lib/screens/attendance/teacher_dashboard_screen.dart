import 'package:flutter/material.dart';
import 'package:shiksha_darpan/screens/attendance/teacher_checkin_screen.dart';
import 'package:shiksha_darpan/screens/attendance/teacher_ratings_screen.dart';
import 'package:shiksha_darpan/screens/auth/login_screen.dart';
import 'package:shiksha_darpan/services/auth_service.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({Key? key}) : super(key: key);

  @override
  _TeacherDashboardScreenState createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TeacherCheckinScreen(), // Note: TeacherCheckinScreen has its own AppBar right now
    const TeacherRatingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0 
        ? null // TeacherCheckinScreen provides its own AppBar
        : AppBar(
            title: const Text('My Ratings'),
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
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Check-in',
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
