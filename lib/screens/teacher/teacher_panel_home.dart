// lib/screens/teacher/teacher_panel_home.dart
// Main Teacher Panel hub – Material Design 3 with indigo theme

import 'package:flutter/material.dart';
import 'package:shiksha_darpan/models/user_model.dart';
import 'package:shiksha_darpan/screens/teacher/class_management_screen.dart';
import 'package:shiksha_darpan/screens/teacher/smart_attendance_screen.dart';
import 'package:shiksha_darpan/screens/teacher/marksheet_screen.dart';
import 'package:shiksha_darpan/screens/teacher/fee_management_screen.dart';
import 'package:shiksha_darpan/screens/teacher/homework_screen.dart';
import 'package:shiksha_darpan/screens/teacher/library_screen.dart';
import 'package:shiksha_darpan/screens/teacher/behavior_screen.dart';
import 'package:shiksha_darpan/screens/teacher/health_records_screen.dart';
import 'package:shiksha_darpan/screens/teacher/id_card_generator_screen.dart';
import 'package:shiksha_darpan/screens/teacher/transport_screen.dart';
import 'package:shiksha_darpan/screens/teacher/exam_timetable_screen.dart';
import 'package:shiksha_darpan/screens/teacher/school_calendar_screen.dart';
import 'package:shiksha_darpan/screens/teacher/online_test_screen.dart';
import 'package:shiksha_darpan/screens/teacher/communication_hub_screen.dart';
import 'package:shiksha_darpan/screens/teacher/digital_library_screen.dart';
import 'package:shiksha_darpan/screens/teacher/sports_screen.dart';
import 'package:shiksha_darpan/screens/teacher/analytics_dashboard_screen.dart';
import 'package:shiksha_darpan/screens/teacher/student_list_screen.dart';
import 'package:shiksha_darpan/screens/student/teacher_achievement_screen.dart';

class TeacherPanelHome extends StatelessWidget {
  const TeacherPanelHome({super.key, this.teacher});
  final UserModel? teacher;

  static const Color _indigo = Color(0xFF3949AB);
  static const Color _indigoDark = Color(0xFF283593);

  UserModel get _t =>
      teacher ??
      UserModel(
        id: 'demo_teacher',
        name: 'Demo Teacher',
        role: UserRole.teacher,
        level: AdministrativeLevel.ground,
        email: '',
        phone: '',
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF0F2FF),
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: _indigo,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white24,
                              child: Text(
                                _t.name.isNotEmpty
                                    ? _t.name[0].toUpperCase()
                                    : 'T',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Teacher Panel',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                  Text(
                                    _t.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _quickStat('Modules', '18'),
                            const SizedBox(width: 16),
                            _quickStat('Class', '8A'),
                            const SizedBox(width: 16),
                            _quickStat('Students', '38'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: const Text(
                'Teacher Panel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          // ── Grid of Module Cards ────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              delegate: SliverChildListDelegate([
                _moduleCard(
                  context,
                  icon: Icons.class_,
                  label: 'Class\nManagement',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)]),
                  onTap: () => _push(
                      context, ClassManagementScreen(teacher: _t)),
                ),
                _moduleCard(
                  context,
                  icon: Icons.people_alt,
                  label: 'Student\nDirectory',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF00838F), Color(0xFF4DD0E1)]),
                  onTap: () => _push(
                      context,
                      StudentListScreen(
                          teacher: _t,
                          grade: 8,
                          section: 'A',
                          schoolUdise: '27201804302')),
                ),
                _moduleCard(
                  context,
                  icon: Icons.calendar_month,
                  label: 'Smart\nAttendance',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)]),
                  onTap: () => _push(
                      context,
                      SmartAttendanceScreen(
                          teacher: _t,
                          grade: 8,
                          section: 'A',
                          schoolUdise: '27201804302')),
                ),
                _moduleCard(
                  context,
                  icon: Icons.grade,
                  label: 'Marks &\nMarksheet',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)]),
                  onTap: () => _push(
                      context, MarksheetScreen(teacher: _t)),
                ),
                _moduleCard(
                  context,
                  icon: Icons.emoji_events,
                  label: 'Achievements',
                  gradient: const LinearGradient(
                      colors: [Color(0xFFE65100), Color(0xFFFF8F00)]),
                  onTap: () => _push(
                      context,
                      TeacherAchievementScreen(teacher: _t)),
                ),
                _moduleCard(
                  context,
                  icon: Icons.payment,
                  label: 'Fee\nManagement',
                  gradient: const LinearGradient(
                      colors: [Color(0xFFC62828), Color(0xFFEF5350)]),
                  onTap: () => _push(
                      context,
                      FeeManagementScreen(
                          schoolUdise: '27201804302')),
                ),
                _moduleCard(
                  context,
                  icon: Icons.book,
                  label: 'Library',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF004D40), Color(0xFF26A69A)]),
                  onTap: () => _push(
                      context,
                      LibraryScreen(schoolUdise: '27201804302')),
                ),
                _moduleCard(
                  context,
                  icon: Icons.assignment,
                  label: 'Homework',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF37474F), Color(0xFF78909C)]),
                  onTap: () => _push(
                      context,
                      HomeworkScreen(teacher: _t)),
                ),
                _moduleCard(
                  context,
                  icon: Icons.psychology,
                  label: 'Behavior &\nDiscipline',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF880E4F), Color(0xFFEC407A)]),
                  onTap: () => _push(
                      context, BehaviorScreen(teacher: _t)),
                ),
                _moduleCard(
                  context,
                  icon: Icons.medical_services,
                  label: 'Health\nRecords',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
                  onTap: () => _push(
                      context,
                      HealthRecordsScreen(schoolUdise: '27201804302')),
                ),
                _moduleCard(
                  context,
                  icon: Icons.badge,
                  label: 'ID Card\nGenerator',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)]),
                  onTap: () => _push(
                      context,
                      IdCardGeneratorScreen(teacher: _t)),
                ),
                _moduleCard(
                  context,
                  icon: Icons.directions_bus,
                  label: 'Transport',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF33691E), Color(0xFF8BC34A)]),
                  onTap: () => _push(
                      context,
                      TransportScreen(schoolUdise: '27201804302')),
                ),
                _moduleCard(
                  context,
                  icon: Icons.event_note,
                  label: 'Exam\nTimetable',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF0277BD), Color(0xFF29B6F6)]),
                  onTap: () => _push(
                      context,
                      ExamTimetableScreen(teacher: _t)),
                ),
                _moduleCard(
                  context,
                  icon: Icons.calendar_today,
                  label: 'School\nCalendar',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF558B2F), Color(0xFFAED581)]),
                  onTap: () => _push(
                      context, SchoolCalendarScreen(
                          schoolUdise: '27201804302')),
                ),
                _moduleCard(
                  context,
                  icon: Icons.quiz,
                  label: 'Online\nTests',
                  gradient: const LinearGradient(
                      colors: [Color(0xFFBF360C), Color(0xFFFF7043)]),
                  onTap: () => _push(
                      context,
                      OnlineTestScreen(teacher: _t)),
                ),
                _moduleCard(
                  context,
                  icon: Icons.forum,
                  label: 'Communication\nHub',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF00695C), Color(0xFF4DB6AC)]),
                  onTap: () => _push(
                      context,
                      CommunicationHubScreen(teacher: _t)),
                ),
                _moduleCard(
                  context,
                  icon: Icons.menu_book,
                  label: 'Digital\nLibrary',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF283593), Color(0xFF5C6BC0)]),
                  onTap: () => _push(
                      context,
                      DigitalLibraryScreen(
                          schoolUdise: '27201804302')),
                ),
                _moduleCard(
                  context,
                  icon: Icons.sports_soccer,
                  label: 'Sports &\nPE',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)]),
                  onTap: () => _push(
                      context,
                      SportsScreen(schoolUdise: '27201804302')),
                ),
                _moduleCard(
                  context,
                  icon: Icons.bar_chart,
                  label: 'Analytics',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF1A237E), Color(0xFF3949AB)]),
                  onTap: () => _push(
                      context, AnalyticsDashboardScreen(teacher: _t)),
                ),
              ]),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _quickStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        Text(label,
            style:
                const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _moduleCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
