// lib/screens/teacher/class_management_screen.dart

import 'package:flutter/material.dart';
import 'package:shiksha_darpan/models/class_section_model.dart';
import 'package:shiksha_darpan/models/user_model.dart';
import 'package:shiksha_darpan/services/class_management_service.dart';
import 'package:shiksha_darpan/screens/teacher/section_detail_screen.dart';

class ClassManagementScreen extends StatefulWidget {
  final UserModel teacher;
  const ClassManagementScreen({super.key, required this.teacher});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  static const String _udise = '27201804302';
  final _svc = ClassManagementService();
  int? _selectedGrade;

  @override
  void initState() {
    super.initState();
    _selectedGrade = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF),
      appBar: AppBar(
        title: const Text('Class Management'),
        backgroundColor: const Color(0xFF3949AB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Seed Demo Classes',
            onPressed: () async {
              await _svc.seedDemoClasses(_udise);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Demo classes seeded successfully!'),
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
          // ── Grade selector strip ───────────────────────────────────────
          Container(
            color: const Color(0xFF3949AB),
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: 12,
              itemBuilder: (context, index) {
                final grade = index + 1;
                final selected = _selectedGrade == grade;
                return GestureDetector(
                  onTap: () => setState(() => _selectedGrade = grade),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          selected ? Colors.white : Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Class $grade',
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF3949AB)
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Sections grid ─────────────────────────────────────────────
          Expanded(
            child: _selectedGrade == null
                ? _buildOverviewGrid()
                : _buildSectionsForGrade(_selectedGrade!),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final grade = index + 1;
        return _gradeCard(grade);
      },
    );
  }

  Widget _gradeCard(int grade) {
    return GestureDetector(
      onTap: () => setState(() => _selectedGrade = grade),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              HSLColor.fromAHSL(1, (grade * 28.0) % 360, 0.6, 0.4)
                  .toColor(),
              HSLColor.fromAHSL(1, (grade * 28.0) % 360, 0.6, 0.55)
                  .toColor(),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Class $grade',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            StreamBuilder<List<SectionModel>>(
              stream: _svc.streamSections(_udise, grade),
              builder: (ctx, snap) {
                final count = snap.data?.length ?? 0;
                return Text(
                  '$count section${count != 1 ? 's' : ''}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionsForGrade(int grade) {
    return StreamBuilder<List<SectionModel>>(
      stream: _svc.streamSections(_udise, grade),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final sections = snap.data ?? [];
        if (sections.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.class_, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('No sections for Class $grade yet'),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Seed Demo Classes'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3949AB),
                      foregroundColor: Colors.white),
                  onPressed: () async {
                    await _svc.seedDemoClasses(_udise);
                  },
                ),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Class $grade – ${sections.length} Sections',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sections.map((s) => _sectionCard(s)),
          ],
        );
      },
    );
  }

  Widget _sectionCard(SectionModel section) {
    final capacityPct =
        section.totalStudents / section.maxStudents;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SectionDetailScreen(
              section: section,
              teacher: widget.teacher,
              schoolUdise: _udise,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        section.section,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.displayName,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        if (section.classTeacherName.isNotEmpty)
                          Text(
                            'Class Teacher: ${section.classTeacherName}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _statChip(Icons.male, '${section.totalBoys}',
                      Colors.blue),
                  const SizedBox(width: 8),
                  _statChip(Icons.female, '${section.totalGirls}',
                      Colors.pink),
                  const SizedBox(width: 8),
                  _statChip(Icons.people, '${section.totalStudents}',
                      Colors.indigo),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: capacityPct,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  capacityPct > 0.9
                      ? Colors.red
                      : capacityPct > 0.7
                          ? Colors.orange
                          : Colors.green,
                ),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 4),
              Text(
                '${section.totalStudents}/${section.maxStudents} capacity',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
