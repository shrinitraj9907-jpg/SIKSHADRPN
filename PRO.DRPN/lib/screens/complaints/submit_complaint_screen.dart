import 'package:flutter/material.dart';
import 'package:shiksha_darpan/services/database_service.dart';
import 'package:shiksha_darpan/models/complaint_model.dart';
import 'package:shiksha_darpan/models/user_model.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({Key? key}) : super(key: key);

  @override
  _SubmitComplaintScreenState createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  bool _isAnonymous = true;
  bool _isLoading = false;
  String _selectedCategory = 'Infrastructure (Toilets/Labs)';
  
  final TextEditingController _udiseController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final List<String> _categories = [
    'Infrastructure (Toilets/Labs)',
    'Teacher Absenteeism',
    'Mid-Day Meal Quality',
    'Fund Mismanagement',
    'Other'
  ];

  Future<void> _submit() async {
    if (_udiseController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final complaint = ComplaintModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        schoolUdiseCode: _udiseController.text,
        title: _selectedCategory,
        description: _descController.text,
        isAnonymous: _isAnonymous,
        submittedDate: DateTime.now(),
        currentEscalationLevel: AdministrativeLevel.ground,
      );

      await DatabaseService().submitComplaint(complaint);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint submitted successfully to Firebase.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lodge a Complaint'),
        backgroundColor: Colors.red[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red[800]),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'ShikshaDarpan\'s Escalation Engine guarantees your issue will automatically move to the Block/State level if not resolved locally within 7 days.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _udiseController,
              decoration: const InputDecoration(
                labelText: 'School UDISE Code',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Complaint Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Detailed Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Submit Anonymously'),
              subtitle: const Text('Your identity will be completely hidden from school officials.'),
              value: _isAnonymous,
              activeColor: Colors.red[800],
              onChanged: (val) => setState(() => _isAnonymous = val),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.send),
                label: Text(_isLoading ? 'Submitting...' : 'Submit Complaint', style: const TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
