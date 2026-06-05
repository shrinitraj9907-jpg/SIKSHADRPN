import 'package:flutter/material.dart';
import 'package:shiksha_darpan/models/pgi_model.dart';

class PgiReportScreen extends StatelessWidget {
  final PgiScoreModel pgiScore;

  const PgiReportScreen({Key? key, required this.pgiScore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PGI Report: ${pgiScore.districtId} (${pgiScore.stateId})'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '70-Indicator Matrix Analysis',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Chip(
                label: Text(pgiScore.grade, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                backgroundColor: _getGradeColor(pgiScore.totalScore),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Analyzing performance across all PGI domains to identify gaps in educational equity and infrastructure.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            'Total Score: ${pgiScore.totalScore.toInt()} / 1000',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const SizedBox(height: 24),
          _buildDomainCard('Learning Outcomes', pgiScore.learningOutcomes, 180, Colors.blue),
          _buildDomainCard('Access & Equity', pgiScore.access + pgiScore.equity, 310, Colors.orange), // Combined for simplicity here, or separate them
          _buildDomainCard('Infrastructure & Facilities', pgiScore.infrastructure, 150, Colors.purple),
          _buildDomainCard('Governance Processes', pgiScore.governanceProcess, 360, Colors.teal),
        ],
      ),
    );
  }

  Color _getGradeColor(double score) {
    if (score > 900) return Colors.green[700]!;
    if (score > 800) return Colors.green;
    if (score > 700) return Colors.orange;
    return Colors.red;
  }

  Widget _buildDomainCard(String title, double score, double maxScore, Color color) {
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              backgroundColor: color.withOpacity(0.2),
              color: color,
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }
}
