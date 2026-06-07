import 'package:flutter/material.dart';

class PgiReportScreen extends StatelessWidget {
  const PgiReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PGI Detailed Report'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            '70-Indicator Matrix Analysis',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Analyzing performance across all PGI domains to identify gaps in educational equity and infrastructure.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _buildDomainCard('Learning Outcomes', 140, 180, Colors.blue),
          _buildDomainCard('Access & Equity', 260, 310, Colors.orange),
          _buildDomainCard(
              'Infrastructure & Facilities', 130, 150, Colors.purple),
          _buildDomainCard('Governance Processes', 290, 360, Colors.teal),
        ],
      ),
    );
  }

  Widget _buildDomainCard(
      String title, double score, double maxScore, Color color) {
    final double percentage = score / maxScore;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${score.toInt()} / ${maxScore.toInt()}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: color.withValues(alpha: 0.2),
              color: color,
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }
}
