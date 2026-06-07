import 'package:flutter/material.dart';
import 'package:shiksha_darpan/models/student_model.dart';
import 'package:shiksha_darpan/screens/student/student_panel_screen.dart';
import 'package:shiksha_darpan/services/student_panel_service.dart';
import 'package:shiksha_darpan/theme/student_panel_theme.dart';

class PrincipalStudentBrowserScreen extends StatelessWidget {
  const PrincipalStudentBrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = StudentPanelService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Records'),
        backgroundColor: StudentPanelTheme.indigo,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<StudentModel>>(
        stream: service.streamStudents(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final students = snap.data ?? [];
          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No students registered yet'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await service.seedDemoStudentData('demo_student_001');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Demo student data seeded.'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Seed Demo Student'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StudentPanelTheme.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final s = students[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        StudentPanelTheme.indigo.withValues(alpha: 0.15),
                    child: Text(
                      s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: StudentPanelTheme.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    s.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Grade ${s.grade} • Roll ${s.rollNumber.isNotEmpty ? s.rollNumber : "—"} • ${s.apaarId}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentPanelScreen(
                          studentId: s.id,
                          readOnly: true,
                          title: 'Student Record',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
