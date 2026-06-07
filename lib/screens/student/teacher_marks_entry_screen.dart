import 'package:flutter/material.dart';
import 'package:shiksha_darpan/models/exam_model.dart';
import 'package:shiksha_darpan/models/student_model.dart';
import 'package:shiksha_darpan/models/subject_mark_model.dart';
import 'package:shiksha_darpan/models/user_model.dart';
import 'package:shiksha_darpan/services/student_panel_service.dart';
import 'package:shiksha_darpan/theme/student_panel_theme.dart';

class TeacherMarksEntryScreen extends StatefulWidget {
  const TeacherMarksEntryScreen({
    super.key,
    required this.teacher,
  });

  final UserModel teacher;

  @override
  State<TeacherMarksEntryScreen> createState() =>
      _TeacherMarksEntryScreenState();
}

class _TeacherMarksEntryScreenState extends State<TeacherMarksEntryScreen> {
  final _service = StudentPanelService();
  final _obtainedCtrl = TextEditingController();
  final _totalCtrl = TextEditingController(text: '100');

  StudentModel? _student;
  ExamModel? _exam;
  String? _subjectKey;
  bool _saving = false;

  List<String> get _subjects => widget.teacher.assignedSubjects.isNotEmpty
      ? widget.teacher.assignedSubjects
      : ['Mathematics', 'Science', 'English', 'Hindi', 'Social Studies'];

  String _subjectId(String name) =>
      name.toLowerCase().replaceAll(' ', '_');

  @override
  void dispose() {
    _obtainedCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveMarks() async {
    if (_student == null || _exam == null || _subjectKey == null) {
      _snack('Select student, exam, and subject.');
      return;
    }

    if (!widget.teacher.canEditSubject(_subjectKey!)) {
      _snack('You can only edit marks for your assigned subjects.');
      return;
    }

    final obtained = double.tryParse(_obtainedCtrl.text);
    final total = double.tryParse(_totalCtrl.text);
    if (obtained == null || total == null || total <= 0) {
      _snack('Enter valid marks.');
      return;
    }
    if (obtained > total) {
      _snack('Obtained marks cannot exceed total.');
      return;
    }

    setState(() => _saving = true);
    try {
      await _service.ensureExamExists(studentId: _student!.id, exam: _exam!);
      await _service.upsertSubjectMark(
        studentId: _student!.id,
        examId: _exam!.id,
        mark: SubjectMarkModel(
          id: _subjectId(_subjectKey!),
          subjectName: _subjectKey!,
          obtainedMarks: obtained,
          totalMarks: total,
          teacherId: widget.teacher.id,
          teacherName: widget.teacher.name,
          updatedAt: DateTime.now(),
        ),
      );
      if (mounted) {
        _snack('Marks saved to Firestore.', success: true);
      }
    } catch (e) {
      if (mounted) _snack('Failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Student Marks'),
        backgroundColor: StudentPanelTheme.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Subjects',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: _subjects
                        .map((s) => Chip(
                              label: Text(s, style: const TextStyle(fontSize: 12)),
                              backgroundColor:
                                  StudentPanelTheme.indigoLight.withOpacity(0.4),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You may only edit marks for these subjects.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<StudentModel>>(
            stream: _service.streamStudents(),
            builder: (context, snap) {
              final students = snap.data ?? [];
              return DropdownButtonFormField<StudentModel>(
                decoration: const InputDecoration(
                  labelText: 'Student',
                  border: OutlineInputBorder(),
                ),
                value: _student,
                items: students
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text('${s.name} (Gr ${s.grade})'),
                      ),
                    )
                    .toList(),
                onChanged: (s) => setState(() {
                  _student = s;
                  _exam = null;
                }),
              );
            },
          ),
          const SizedBox(height: 12),
          if (_student != null)
            StreamBuilder<List<ExamModel>>(
              stream: _service.streamExams(_student!.id, year: year),
              builder: (context, snap) {
                final exams = snap.data ?? [];
                final defaultExams = exams.isNotEmpty
                    ? exams
                    : [
                        ExamModel(
                          id: '${year}_unitTest1',
                          studentId: _student!.id,
                          type: ExamType.unitTest1,
                          year: year,
                          name: 'Unit Test 1',
                          sortOrder: 1,
                        ),
                        ExamModel(
                          id: '${year}_unitTest2',
                          studentId: _student!.id,
                          type: ExamType.unitTest2,
                          year: year,
                          name: 'Unit Test 2',
                          sortOrder: 2,
                        ),
                        ExamModel(
                          id: '${year}_halfYearly',
                          studentId: _student!.id,
                          type: ExamType.halfYearly,
                          year: year,
                          name: 'Half Yearly',
                          sortOrder: 3,
                        ),
                        ExamModel(
                          id: '${year}_annual',
                          studentId: _student!.id,
                          type: ExamType.annual,
                          year: year,
                          name: 'Annual',
                          sortOrder: 4,
                        ),
                      ];

                return DropdownButtonFormField<ExamModel>(
                  decoration: const InputDecoration(
                    labelText: 'Exam',
                    border: OutlineInputBorder(),
                  ),
                  value: _exam,
                  items: defaultExams
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name),
                        ),
                      )
                      .toList(),
                  onChanged: (e) => setState(() => _exam = e),
                );
              },
            ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Subject (your assignment)',
              border: OutlineInputBorder(),
            ),
            value: _subjectKey,
            items: _subjects
                .map(
                  (s) => DropdownMenuItem(value: s, child: Text(s)),
                )
                .toList(),
            onChanged: (s) => setState(() => _subjectKey = s),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _obtainedCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Obtained Marks',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _totalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total Marks',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _saveMarks,
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: const Text('Submit & Auto-Save to Firestore'),
              style: ElevatedButton.styleFrom(
                backgroundColor: StudentPanelTheme.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
