import 'package:flutter/material.dart';
import 'package:shiksha_darpan/screens/complaints/submit_complaint_screen.dart';
import 'package:shiksha_darpan/screens/auth/login_screen.dart';
import 'package:shiksha_darpan/services/auth_service.dart';
import 'package:shiksha_darpan/services/database_service.dart';

class TeacherCheckinScreen extends StatefulWidget {
  const TeacherCheckinScreen({Key? key}) : super(key: key);

  @override
  _TeacherCheckinScreenState createState() => _TeacherCheckinScreenState();
}

class _TeacherCheckinScreenState extends State<TeacherCheckinScreen> {
  bool _isCheckedIn = false;
  bool _isLoading = false;
  DateTime? _checkinTime;

  Future<void> _handleCheckin() async {
    setState(() => _isLoading = true);

    try {
      final uid = AuthService().currentFirebaseUser?.uid;
      if (uid == null) {
        throw Exception('Not signed in');
      }
      final now = DateTime.now();
      await DatabaseService().logTeacherCheckin(uid, now);

      if (mounted) {
        setState(() {
          _isCheckedIn = true;
          _checkinTime = now;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-in successful securely logged!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to check in: $e'), backgroundColor: Colors.red),
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
        title: const Text('Ground Level: Teacher Check-in'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await AuthService().signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school,
                size: 80,
                color: Colors.indigo,
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to ShikshaDarpan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please record your daily attendance.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              if (_isCheckedIn) ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Checked in at ${_checkinTime?.hour}:${_checkinTime?.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ] else
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleCheckin,
                  icon: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.location_on),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    child: Text(_isLoading ? 'Checking in...' : 'Check-in Now', style: const TextStyle(fontSize: 18)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              const SizedBox(height: 48),
              const Divider(),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitComplaintScreen()));
                },
                icon: const Icon(Icons.report_problem, color: Colors.red),
                label: const Text('Report an Issue / Escalate', style: TextStyle(color: Colors.red, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
