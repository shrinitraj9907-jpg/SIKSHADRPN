import 'package:flutter/material.dart';
import 'package:shiksha_darpan/screens/complaints/escalation_dashboard.dart';
import 'package:shiksha_darpan/screens/auth/login_screen.dart';

class StateDashboardScreen extends StatelessWidget {
  final String userName;
  final String userRole; // e.g., "Director of Education"
  final String stateName;

  const StateDashboardScreen({
    Key? key,
    this.userName = 'Director',
    this.userRole = 'DPI',
    this.stateName = 'Maharashtra',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level 3: State Executive Dashboard'),
        backgroundColor: Colors.deepPurple,
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
            _buildPgiOverview(),
            const SizedBox(height: 24),
            _buildEscalationAction(context),
            const SizedBox(height: 24),
            const Text(
              'District Performance Tracker',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDistrictList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.deepPurple,
            child: const Icon(Icons.account_balance, size: 30, color: Colors.white),
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
                  '$userRole | Govt. of $stateName',
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPgiOverview() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'State PGI Score (Overall)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '820 / 1000',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Grade: Uttam',
                    style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.82,
              backgroundColor: Colors.grey[200],
              color: Colors.deepPurple,
              minHeight: 10,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('Learning', '140/180'),
                _buildMiniStat('Infrastructure', '130/150'),
                _buildMiniStat('Governance', '290/360'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildDistrictList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        final districts = ['Pune', 'Mumbai', 'Nagpur', 'Nashik'];
        final grades = ['Ati-Uttam', 'Utkarsh', 'Uttam', 'Prachesta-1'];
        final scores = [860, 910, 815, 780];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple[100],
              child: Text('${index + 1}'),
            ),
            title: Text(districts[index], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Score: ${scores[index]} | Grade: ${grades[index]}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to District drill-down
            },
          ),
        );
      },
    );
  }

  Widget _buildEscalationAction(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const EscalationDashboardScreen(userLevel: 'State (DPI)')));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.inbox, color: Colors.red[800], size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Escalation Inbox', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[900])),
                  const Text('Review unresolved district-level complaints.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.red[800]),
          ],
        ),
      ),
    );
  }
}
