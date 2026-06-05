import 'package:flutter/material.dart';
import 'package:shiksha_darpan/screens/complaints/escalation_dashboard.dart';
import 'package:shiksha_darpan/screens/auth/login_screen.dart';

class DistrictDashboardScreen extends StatelessWidget {
  final String userName;
  final String userRole; // e.g., "District Education Officer (DEO)"
  final String districtName;

  const DistrictDashboardScreen({
    Key? key,
    this.userName = 'Officer',
    this.userRole = 'DEO',
    this.districtName = 'Central District',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level 2: District Dashboard'),
        backgroundColor: Colors.teal[700],
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
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatCards(),
            const SizedBox(height: 24),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActionGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.teal[700],
            child: const Icon(Icons.person, size: 35, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $userName',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$userRole | $districtName',
                  style: TextStyle(fontSize: 16, color: Colors.teal[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Total Schools', '142', Icons.business, Colors.blue),
        _buildStatCard('Pending Inspections', '18', Icons.pending_actions, Colors.orange),
        _buildStatCard('Avg Attendance', '84%', Icons.people, Colors.green),
        _buildStatCard('Critical Issues', '3', Icons.warning, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color[600]),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color[800]),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildActionButton('View Schools', Icons.list, Colors.blueGrey, () {}),
        _buildActionButton('Log Inspection', Icons.edit_document, Colors.teal, () {}),
        _buildActionButton('Escalation Inbox', Icons.inbox, Colors.red, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const EscalationDashboardScreen(userLevel: 'District (DEO)')));
        }),
        _buildActionButton('Teacher Directory', Icons.contact_page, Colors.indigo, () {}),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
