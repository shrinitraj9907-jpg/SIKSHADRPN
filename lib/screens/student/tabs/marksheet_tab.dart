import 'package:flutter/material.dart';
import 'package:shiksha_darpan/models/exam_model.dart';
import 'package:shiksha_darpan/models/student_model.dart';
import 'package:shiksha_darpan/models/subject_mark_model.dart';
import 'package:shiksha_darpan/screens/student/widgets/printable_marksheet_card.dart';
import 'package:shiksha_darpan/services/student_panel_service.dart';
import 'package:shiksha_darpan/theme/student_panel_theme.dart';
import 'package:shiksha_darpan/utils/marksheet_calculator.dart';

class MarksheetTab extends StatefulWidget {
  const MarksheetTab({
    super.key,
    required this.studentId,
    this.readOnly = true,
  });

  final String studentId;
  final bool readOnly;

  @override
  State<MarksheetTab> createState() => _MarksheetTabState();
}

class _MarksheetTabState extends State<MarksheetTab> {
  final _service = StudentPanelService();
  final int _year = DateTime.now().year;
  ExamModel? _selectedExam;
  Map<String, List<SubjectMarkModel>> _allMarksBySubject = {};

  @override
  void initState() {
    super.initState();
    _loadAnnualData();
  }

  Future<void> _loadAnnualData() async {
    final data = await _service.fetchAllMarksBySubject(
      widget.studentId,
      year: _year,
    );
    if (mounted) setState(() => _allMarksBySubject = data);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StudentModel?>(
      stream: _service.streamStudent(widget.studentId),
      builder: (context, studentSnap) {
        final student = studentSnap.data;
        return StreamBuilder<List<ExamModel>>(
          stream: _service.streamExams(widget.studentId, year: _year),
          builder: (context, examSnap) {
            if (examSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final exams = examSnap.data ?? [];
            if (exams.isNotEmpty && _selectedExam == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _selectedExam = exams.first);
              });
            }
            final exam = _selectedExam ??
                (exams.isNotEmpty ? exams.first : null);

            if (student == null || exam == null) {
              return _emptyState();
            }

            return StreamBuilder<List<SubjectMarkModel>>(
              stream: _service.streamExamSubjects(widget.studentId, exam.id),
              builder: (context, marksSnap) {
                final subjects = marksSnap.data ?? [];
                final summary = MarksheetCalculator.buildSummary(
                  selectedExamMarks: subjects,
                  allExamMarksBySubject: _allMarksBySubject,
                );

                return RefreshIndicator(
                  onRefresh: _loadAnnualData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _examSelector(exams, exam),
                      const SizedBox(height: 16),
                      PrintableMarksheetCard(
                        student: student,
                        exam: exam,
                        subjects: subjects,
                        summary: summary,
                        year: _year,
                      ),
                      const SizedBox(height: 16),
                      _subjectList(subjects),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No marksheet data yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Your teachers will publish exam marks here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _examSelector(List<ExamModel> exams, ExamModel selected) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<ExamModel>(
            isExpanded: true,
            value: selected,
            items: exams
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text('${e.name} ($_year)'),
                  ),
                )
                .toList(),
            onChanged: (e) {
              if (e != null) setState(() => _selectedExam = e);
            },
          ),
        ),
      ),
    );
  }

  Widget _subjectList(List<SubjectMarkModel> subjects) {
    if (subjects.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subject Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: StudentPanelTheme.indigoDark,
              ),
            ),
            const SizedBox(height: 12),
            ...subjects.map((s) {
              final pct = s.percentage;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.subjectName,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          '${s.obtainedMarks.toStringAsFixed(0)} / ${s.totalMarks.toStringAsFixed(0)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        minHeight: 8,
                        backgroundColor: StudentPanelTheme.indigoLight,
                        color: StudentPanelTheme.indigo,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
