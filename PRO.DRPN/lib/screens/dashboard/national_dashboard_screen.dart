import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shiksha_darpan/screens/auth/login_screen.dart';

class NationalDashboardScreen extends StatelessWidget {
  final String userName;
  final String userRole; // e.g., "Union Education Minister"

  const NationalDashboardScreen({
    Key? key,
    this.userName = 'Honorable Minister',
    this.userRole = 'Ministry of Education (MoE)',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level 4: MoE National Dashboard'),
        backgroundColor: Colors.indigo[900],
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
            const Text(
              'National Education Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildKeyMetricsRow(),
            const SizedBox(height: 24),
            _buildPrabandhBudgetSection(),
            const SizedBox(height: 24),
            const Text(
              'Interactive PGI Map (India)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildIndiaMapSection(),
            const SizedBox(height: 24),
            const Text(
              'Top Performing States',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStateRankingList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.indigo[900],
            child: const Icon(Icons.public, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  userRole,
                  style: TextStyle(fontSize: 16, color: Colors.indigo[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsRow() {
    return Row(
      children: [
        Expanded(child: _buildMetricCard('Total Schools', '1.5M', Icons.school)),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard('Total Students', '260M', Icons.groups)),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.indigo[600]),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrabandhBudgetSection() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PRABANDH Fund Utilization',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.account_balance_wallet, color: Colors.green[700]),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Total Allocation: ₹ 45,000 Cr', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: [
                        PieChartSectionData(
                          color: Colors.green,
                          value: 38500,
                          title: '85.5%',
                          radius: 40,
                          titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.grey[300]!,
                          value: 6500,
                          title: '',
                          radius: 30,
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Utilized\n₹ 38.5k Cr',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndiaMapSection() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo[200]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(20.5937, 78.9629), // Center of India
            initialZoom: 4.0,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.shikshadarpan',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: const LatLng(28.6139, 77.2090), // Delhi
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
                Marker(
                  point: const LatLng(19.0760, 72.8777), // Mumbai
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateRankingList() {
    // Mock data for top states
    final states = ['Kerala', 'Punjab', 'Maharashtra'];
    final grades = ['Daksh', 'Utkarsh', 'Uttam'];
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: states.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo[100],
              child: Text('${index + 1}'),
            ),
            title: Text(states[index], style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Chip(
              label: Text(grades[index]),
              backgroundColor: Colors.indigo[50],
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
}
