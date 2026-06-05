import 'package:flutter/material.dart';
import 'package:shiksha_darpan/screens/auth/login_screen.dart';

class PrincipalDashboardScreen extends StatelessWidget {
  const PrincipalDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Command Centre'),
        backgroundColor: Colors.blueGrey[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Principal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Govt. Senior Secondary School (UDISE: 27201804302)',
              style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
            ),
            const SizedBox(height: 24),
            _buildSchoolStats(),
            const SizedBox(height: 32),
            const Text(
              'Complaint Resolution Queue',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildComplaintQueue(),
            const SizedBox(height: 32),
            const Text(
              'Today\'s Teacher Attendance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTeacherAttendance(),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolStats() {
    return Row(
      children: [
        _buildStatCard('Students', '840', Icons.groups, Colors.blue),
        const SizedBox(width: 12),
        _buildStatCard('Present Today', '92%', Icons.check_circle, Colors.green),
        const SizedBox(width: 12),
        _buildStatCard('Issues', '2', Icons.warning, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintQueue() {
    // Mock active complaints that are ticking down before escalation
    final complaints = [
      {'title': 'No Water in Girls Toilet', 'timeLeft': '48h 12m', 'color': Colors.orange},
      {'title': 'Mid-Day Meal Delayed', 'timeLeft': '05h 30m', 'color': Colors.red},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final c = complaints[index];
        final isCritical = (c['color'] as Color) == Colors.red;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (c['color'] as Color).withOpacity(0.2),
              child: Icon(Icons.timer, color: c['color'] as Color),
            ),
            title: Text(c['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Escalates in: ${c['timeLeft']}',
              style: TextStyle(
                color: isCritical ? Colors.red : Colors.orange[800],
                fontWeight: isCritical ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[800],
                foregroundColor: Colors.white,
              ),
              child: const Text('Resolve'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeacherAttendance() {
    final teachers = [
      {'name': 'Ramesh Kumar (Math)', 'status': 'Present (GPS Verified)', 'icon': Icons.location_on, 'color': Colors.green},
      {'name': 'Sunita Sharma (Science)', 'status': 'Present (GPS Verified)', 'icon': Icons.location_on, 'color': Colors.green},
      {'name': 'Anil Desai (English)', 'status': 'Absent', 'icon': Icons.cancel, 'color': Colors.red},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final t = teachers[index];
        return Card(
          child: ListTile(
            leading: Icon(t['icon'] as IconData, color: t['color'] as Color),
            title: Text(t['name'] as String),
            subtitle: Text(
              t['status'] as String,
              style: TextStyle(color: t['color'] as Color),
            ),
          ),
        );
      },
    );
  }
}
