import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ParakhAssessmentScreen extends StatelessWidget {
  const ParakhAssessmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NAS / PARAKH National Report'),
        backgroundColor: Colors.indigo[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Competency-Based Assessment Data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Identifying learning gaps across foundational, preparatory, and middle stages.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildNipunBharatCard(),
            const SizedBox(height: 24),
            const Text(
              'NAS Class 3, 5, 8 & 10 Averages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildNasBarChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildNipunBharatCard() {
    return Card(
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.auto_stories, color: Colors.amber[800]),
                const SizedBox(width: 8),
                Text(
                  'NIPUN Bharat Mission',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber[900]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Target: Universal foundational literacy and numeracy by Grade 3.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCircularStat('Literacy', 68.5, Colors.amber[800]!),
                _buildCircularStat('Numeracy', 62.0, Colors.amber[800]!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularStat(String label, double percentage, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 8,
                color: color,
                backgroundColor: color.withOpacity(0.2),
              ),
            ),
            Text(
              '${percentage}%',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildNasBarChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
                      String text;
                      switch (value.toInt()) {
                        case 0: text = 'Class 3'; break;
                        case 1: text = 'Class 5'; break;
                        case 2: text = 'Class 8'; break;
                        case 3: text = 'Class 10'; break;
                        default: text = ''; break;
                      }
                      return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(text, style: style));
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}%', style: const TextStyle(fontSize: 12, color: Colors.grey));
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 72, color: Colors.teal, width: 20, borderRadius: BorderRadius.circular(4))]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 65, color: Colors.blue, width: 20, borderRadius: BorderRadius.circular(4))]),
                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 54, color: Colors.orange, width: 20, borderRadius: BorderRadius.circular(4))]),
                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 48, color: Colors.red, width: 20, borderRadius: BorderRadius.circular(4))]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
