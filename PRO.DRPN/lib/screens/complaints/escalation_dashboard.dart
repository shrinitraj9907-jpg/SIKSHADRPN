import 'package:flutter/material.dart';

class EscalationDashboardScreen extends StatelessWidget {
  final String userLevel; // e.g., "Intermediate Level (DEO)"

  const EscalationDashboardScreen({Key? key, this.userLevel = 'Intermediate (District)'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escalation Inbox'),
        backgroundColor: Colors.red[900],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.red[50],
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.red[900], size: 30),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Viewing complaints auto-escalated to $userLevel because they exceeded the 7-day SLA at the lower level.',
                    style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3, // Mock data
              itemBuilder: (context, index) {
                final issues = ['Fund Mismanagement (Mid-Day Meal)', 'No Functional Toilets', 'Chronic Teacher Absenteeism'];
                final udiseCodes = ['27250100201', '27250100445', '27250100892'];
                final daysOverdue = [12, 9, 8];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.red[300]!, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: const Text('Anonymous', style: TextStyle(color: Colors.white, fontSize: 12)),
                              backgroundColor: Colors.grey[800],
                            ),
                            Text(
                              'Escalated: ${daysOverdue[index]} days ago',
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          issues[index],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('School UDISE: ${udiseCodes[index]}', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.remove_red_eye),
                              label: const Text('View Evidence'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800], foregroundColor: Colors.white),
                              child: const Text('Take Action'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
