import 'package:flutter/material.dart';
import 'package:shiksha_darpan/services/database_service.dart';
import 'package:shiksha_darpan/models/lesson_log_model.dart';

class LessonLogsScreen extends StatefulWidget {
  const LessonLogsScreen({Key? key}) : super(key: key);

  @override
  _LessonLogsScreenState createState() => _LessonLogsScreenState();
}

class _LessonLogsScreenState extends State<LessonLogsScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  double _completionPercentage = 0;
  bool _isLoading = false;

  Future<void> _submitLog() async {
    if (_subjectController.text.isEmpty || _topicController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter subject and topic')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final log = LessonLogModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        teacherId: 'mock_teacher_123',
        subject: _subjectController.text,
        topic: _topicController.text,
        completionPercentage: _completionPercentage.toInt(),
        date: DateTime.now(),
      );

      await DatabaseService().submitLessonLog(log);

      if (mounted) {
        _subjectController.clear();
        _topicController.clear();
        setState(() => _completionPercentage = 0);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson log submitted!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Record Today\'s Lesson',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(
              labelText: 'Subject (e.g., Mathematics)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.book),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _topicController,
            decoration: const InputDecoration(
              labelText: 'Topic Covered',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.topic),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Syllabus Completion: ${_completionPercentage.toInt()}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _completionPercentage,
            min: 0,
            max: 100,
            divisions: 20,
            label: '${_completionPercentage.toInt()}%',
            onChanged: (val) => setState(() => _completionPercentage = val),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitLog,
              icon: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.save),
              label: Text(_isLoading ? 'Saving...' : 'Submit Log'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Recent Logs',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<LessonLogModel>>(
            stream: DatabaseService().getTeacherLessonLogs('mock_teacher_123'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No lesson logs found.');
              }
              final logs = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: Icon(Icons.book, color: Colors.white),
                      ),
                      title: Text('${log.subject} - ${log.topic}'),
                      subtitle: Text('Completion: ${log.completionPercentage}%'),
                      trailing: Text(
                        '${log.date.day}/${log.date.month}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
