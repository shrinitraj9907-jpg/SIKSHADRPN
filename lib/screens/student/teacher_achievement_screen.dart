import 'package:flutter/material.dart';
import 'package:shiksha_darpan/models/achievement_model.dart';
import 'package:shiksha_darpan/models/student_model.dart';
import 'package:shiksha_darpan/models/user_model.dart';
import 'package:shiksha_darpan/services/student_panel_service.dart';
import 'package:shiksha_darpan/theme/student_panel_theme.dart';

class TeacherAchievementScreen extends StatefulWidget {
  const TeacherAchievementScreen({super.key, required this.teacher});

  final UserModel teacher;

  @override
  State<TeacherAchievementScreen> createState() =>
      _TeacherAchievementScreenState();
}

class _TeacherAchievementScreenState extends State<TeacherAchievementScreen> {
  final _service = StudentPanelService();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _photoCtrl = TextEditingController();

  StudentModel? _student;
  AchievementCategory _category = AchievementCategory.academics;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _photoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (_student == null || _titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select student and enter title.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final id = 'ach_${DateTime.now().millisecondsSinceEpoch}';
      await _service.addAchievement(
        AchievementModel(
          id: id,
          studentId: _student!.id,
          title: _titleCtrl.text.trim(),
          date: _date,
          category: _category,
          description: _descCtrl.text.trim(),
          photoUrl:
              _photoCtrl.text.trim().isEmpty ? null : _photoCtrl.text.trim(),
          addedByTeacherId: widget.teacher.id,
          addedByTeacherName: widget.teacher.name,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Achievement added!'),
            backgroundColor: Colors.green,
          ),
        );
        _titleCtrl.clear();
        _descCtrl.clear();
        _photoCtrl.clear();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Achievement'),
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
          const SizedBox(height: 12),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Achievement Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<AchievementCategory>(
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            initialValue: _category,
            items: AchievementCategory.values
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.label),
                  ),
                )
                .toList(),
            onChanged: (c) {
              if (c != null) setState(() => _category = c);
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(
              '${_date.day}/${_date.month}/${_date.year}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _pickDate,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _photoCtrl,
            decoration: const InputDecoration(
              labelText: 'Photo URL (optional)',
              border: OutlineInputBorder(),
              hintText: 'https://...',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _submit,
              icon: const Icon(Icons.add),
              label: const Text('Add Achievement'),
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
