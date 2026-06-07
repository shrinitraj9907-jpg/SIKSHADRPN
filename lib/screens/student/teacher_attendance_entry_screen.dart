import 'package:flutter/material.dart';
import 'package:shiksha_darpan/models/student_attendance_model.dart';
import 'package:shiksha_darpan/models/student_model.dart';
import 'package:shiksha_darpan/services/student_panel_service.dart';
import 'package:shiksha_darpan/theme/student_panel_theme.dart';

class TeacherAttendanceEntryScreen extends StatefulWidget {
  const TeacherAttendanceEntryScreen({super.key});

  @override
  State<TeacherAttendanceEntryScreen> createState() =>
      _TeacherAttendanceEntryScreenState();
}

class _TeacherAttendanceEntryScreenState
    extends State<TeacherAttendanceEntryScreen> {
  final _service = StudentPanelService();
  StudentModel? _student;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  int _selectedDay = DateTime.now().day;
  AttendanceDayStatus _status = AttendanceDayStatus.present;
  bool _saving = false;

  Future<void> _save() async {
    if (_student == null) return;
    setState(() => _saving = true);
    try {
      await _service.setAttendanceDay(
        studentId: _student!.id,
        year: _month.year,
        month: _month.month,
        day: _selectedDay,
        status: _status,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance saved.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: StudentPanelTheme.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StreamBuilder<List<StudentModel>>(
            stream: _service.streamStudents(),
            builder: (context, snap) {
              final students = snap.data ?? [];
              return DropdownButtonFormField<StudentModel>(
                decoration: const InputDecoration(
                  labelText: 'Student',
                  border: OutlineInputBorder(),
                ),
                initialValue: _student,
                items: students
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text('${s.name} (Gr ${s.grade})'),
                      ),
                    )
                    .toList(),
                onChanged: (s) => setState(() => _student = s),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() {
                  _month = DateTime(_month.year, _month.month - 1);
                }),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  '${_month.month}/${_month.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _month = DateTime(_month.year, _month.month + 1);
                }),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Day',
              border: OutlineInputBorder(),
            ),
            initialValue: _selectedDay.clamp(1, daysInMonth),
            items: List.generate(
              daysInMonth,
              (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
            ),
            onChanged: (d) {
              if (d != null) setState(() => _selectedDay = d);
            },
          ),
          const SizedBox(height: 12),
          const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<AttendanceDayStatus>(
            segments: const [
              ButtonSegment(
                value: AttendanceDayStatus.present,
                label: Text('Present'),
                icon: Icon(Icons.check),
              ),
              ButtonSegment(
                value: AttendanceDayStatus.absent,
                label: Text('Absent'),
                icon: Icon(Icons.close),
              ),
              ButtonSegment(
                value: AttendanceDayStatus.holiday,
                label: Text('Holiday'),
                icon: Icon(Icons.star),
              ),
            ],
            selected: {_status},
            onSelectionChanged: (s) => setState(() => _status = s.first),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _saving || _student == null ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: StudentPanelTheme.indigo,
                foregroundColor: Colors.white,
              ),
              child: _saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Attendance'),
            ),
          ),
        ],
      ),
    );
  }
}
