// lib/screens/teacher/section_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:shiksha_darpan/models/class_section_model.dart';
import 'package:shiksha_darpan/models/enhanced_student_model.dart';
import 'package:shiksha_darpan/models/user_model.dart';
import 'package:shiksha_darpan/services/class_management_service.dart';
import 'package:shiksha_darpan/screens/teacher/student_profile_screen.dart';
import 'package:shiksha_darpan/screens/teacher/add_edit_student_screen.dart';

class SectionDetailScreen extends StatefulWidget {
  final SectionModel section;
  final UserModel teacher;
  final String schoolUdise;

  const SectionDetailScreen({
    super.key,
    required this.section,
    required this.teacher,
    required this.schoolUdise,
  });

  @override
  State<SectionDetailScreen> createState() => _SectionDetailScreenState();
}

class _SectionDetailScreenState extends State<SectionDetailScreen> {
  final _svc = ClassManagementService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF),
      appBar: AppBar(
        title: Text(widget.section.displayName),
        backgroundColor: const Color(0xFF3949AB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Student',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditStudentScreen(
                    section: widget.section,
                    schoolUdise: widget.schoolUdise,
                  ),
                ),
              );
              if (result == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Student added successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Section Stats Header ─────────────────────────────────────
          Container(
            color: const Color(0xFF3949AB),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _headerStat('Class Teacher',
                    widget.section.classTeacherName.isNotEmpty
                        ? widget.section.classTeacherName
                        : 'Not assigned',
                    Icons.person),
                const SizedBox(width: 16),
                _headerStat('Boys', '${widget.section.totalBoys}',
                    Icons.male),
                const SizedBox(width: 16),
                _headerStat('Girls', '${widget.section.totalGirls}',
                    Icons.female),
                const SizedBox(width: 16),
                _headerStat('Total',
                    '${widget.section.totalStudents}', Icons.groups),
              ],
            ),
          ),

          // ── Search Bar ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search student by name or roll...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // ── Student List ─────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<EnhancedStudentModel>>(
              stream: _svc.streamSectionStudents(
                widget.schoolUdise,
                widget.section.grade,
                widget.section.section,
              ),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var students = snap.data ?? [];
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  students = students
                      .where((s) =>
                          s.name.toLowerCase().contains(q) ||
                          s.rollNumber.toLowerCase().contains(q) ||
                          s.admissionNumber.toLowerCase().contains(q))
                      .toList();
                }
                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school_outlined,
                            size: 72, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No students in this section yet'
                              : 'No students match "$_searchQuery"',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add First Student'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3949AB),
                                foregroundColor: Colors.white),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditStudentScreen(
                                  section: widget.section,
                                  schoolUdise: widget.schoolUdise,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: students.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) =>
                      _studentTile(students[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white54, size: 14),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 10)),
            ],
          ),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _studentTile(EnhancedStudentModel student) {
    final isMale = student.gender == StudentGender.male;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentProfileScreen(
              student: student,
              teacher: widget.teacher,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    isMale ? Colors.blue[50] : Colors.pink[50],
                backgroundImage: student.photoUrl != null &&
                        student.photoUrl!.isNotEmpty
                    ? NetworkImage(student.photoUrl!)
                    : null,
                child: student.photoUrl == null || student.photoUrl!.isEmpty
                    ? Text(
                        student.name.isNotEmpty
                            ? student.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: isMale
                              ? Colors.blue[700]
                              : Colors.pink[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Row(
                      children: [
                        Text('Roll: ${student.rollNumber}  ',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        Text(
                            student.category.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.indigo[600],
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              // Attendance badge
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: student.attendancePercentage >= 75
                          ? Colors.green.withOpacity(0.12)
                          : Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${student.attendancePercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: student.attendancePercentage >= 75
                            ? Colors.green[700]
                            : Colors.red[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text('attend.',
                      style: TextStyle(fontSize: 9, color: Colors.grey)),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
