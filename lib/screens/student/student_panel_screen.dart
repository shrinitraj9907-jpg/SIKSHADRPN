import 'package:flutter/material.dart';
import 'package:shiksha_darpan/models/student_model.dart';
import 'package:shiksha_darpan/screens/auth/login_screen.dart';
import 'package:shiksha_darpan/screens/student/tabs/achievements_tab.dart';
import 'package:shiksha_darpan/screens/student/tabs/attendance_tab.dart';
import 'package:shiksha_darpan/screens/student/tabs/marksheet_tab.dart';
import 'package:shiksha_darpan/services/auth_service.dart';
import 'package:shiksha_darpan/services/student_panel_service.dart';
import 'package:shiksha_darpan/theme/student_panel_theme.dart';

class StudentPanelScreen extends StatelessWidget {
  const StudentPanelScreen({
    super.key,
    required this.studentId,
    this.readOnly = true,
    this.title = 'My Student Panel',
  });

  final String studentId;
  final bool readOnly;
  final String title;

  @override
  Widget build(BuildContext context) {
    final service = StudentPanelService();

    return Theme(
      data: StudentPanelTheme.panelTheme(context),
      child: DefaultTabController(
        length: 3,
        child: StreamBuilder<StudentModel?>(
          stream: service.streamStudent(studentId),
          builder: (context, snap) {
            final student = snap.data;
            return Scaffold(
              backgroundColor: const Color(0xFFF5F6FA),
              appBar: AppBar(
                title: Column(
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16)),
                    if (student != null)
                      Text(
                        '${student.name} • Grade ${student.grade}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                  ],
                ),
                bottom: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.description), text: 'Marksheet'),
                    Tab(icon: Icon(Icons.calendar_month), text: 'Attendance'),
                    Tab(icon: Icon(Icons.emoji_events), text: 'Achievements'),
                  ],
                ),
                actions: [
                  if (!readOnly)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Reload',
                      onPressed: () =>
                          service.seedDemoStudentData(studentId),
                    ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Logout',
                    onPressed: () async {
                      await AuthService().signOut();
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: TabBarView(
                children: [
                  MarksheetTab(studentId: studentId, readOnly: readOnly),
                  AttendanceTab(studentId: studentId),
                  AchievementsTab(studentId: studentId),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
