import 'package:flutter/material.dart';
import 'package:shiksha_darpan/models/user_model.dart';
import 'package:shiksha_darpan/screens/student/teacher_achievement_screen.dart';
import 'package:shiksha_darpan/screens/student/teacher_attendance_entry_screen.dart';
import 'package:shiksha_darpan/screens/student/teacher_marks_entry_screen.dart';
import 'package:shiksha_darpan/theme/student_panel_theme.dart';

class TeacherStudentHubScreen extends StatelessWidget {
  const TeacherStudentHubScreen({super.key, this.teacher});

  final UserModel? teacher;

  UserModel get _teacher =>
      teacher ??
      UserModel(
        id: 'demo_teacher',
        name: 'Demo Teacher',
        role: UserRole.teacher,
        level: AdministrativeLevel.ground,
        email: 'teacher@school.edu',
        phone: '',
        assignedSubjects: const [
          'Mathematics',
          'Science',
          'English',
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: StudentPanelTheme.indigo,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student Panel Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Logged in as ${_teacher.name}',
                    style: const TextStyle(color: Color(0xCCFFFFFF)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _actionCard(
            context,
            icon: Icons.grade,
            title: 'Enter / Update Marks',
            subtitle:
                'Add marks for your assigned subjects only. Auto-saves to Firestore.',
            color: StudentPanelTheme.indigo,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TeacherMarksEntryScreen(teacher: _teacher),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _actionCard(
            context,
            icon: Icons.calendar_month,
            title: 'Mark Attendance',
            subtitle: 'Record present, absent, or holiday for a student.',
            color: const Color(0xFF3949AB),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TeacherAttendanceEntryScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _actionCard(
            context,
            icon: Icons.emoji_events,
            title: 'Add Achievement',
            subtitle:
                'Record sports, academic, or extracurricular achievements.',
            color: const Color(0xFF5C6BC0),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TeacherAchievementScreen(teacher: _teacher),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Assigned Subjects',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _teacher.assignedSubjects
                        .map(
                          (s) => Chip(
                            label: Text(s),
                            backgroundColor: StudentPanelTheme.indigoLight
                                .withValues(alpha: 0.5),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
