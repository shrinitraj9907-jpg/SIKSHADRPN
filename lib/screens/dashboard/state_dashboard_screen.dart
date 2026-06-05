import 'package:flutter/material.dart';
import 'package:shiksha_darpan/screens/complaints/escalation_dashboard.dart';
import 'package:shiksha_darpan/screens/auth/login_screen.dart';
import 'package:shiksha_darpan/services/auth_service.dart';
import 'package:shiksha_darpan/models/user_model.dart';
import 'package:shiksha_darpan/models/pgi_model.dart';
import 'package:shiksha_darpan/services/database_service.dart';
import 'package:shiksha_darpan/screens/reports/pgi_report_screen.dart';

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
    final dbService = DatabaseService();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level 3: State Executive Dashboard'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt),
            tooltip: 'Seed PGI Data',
            onPressed: () async {
              await dbService.seedMockPgiData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeded PGI Data!')));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await AuthService().signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<PgiScoreModel>>(
        stream: dbService.streamStateDistrictPgiScores(stateName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final scores = snapshot.data ?? [];
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildPgiOverview(scores),
                const SizedBox(height: 24),
                _buildEscalationAction(context),
                const SizedBox(height: 24),
                const Text(
                  'District Performance Tracker',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildDistrictList(context, scores),
              ],
            ),
          );
        }
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

  Widget _buildPgiOverview(List<PgiScoreModel> scores) {
    if (scores.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No PGI data available. Tap the bolt icon to seed.'),
        ),
      );
    }
    
    // Calculate state averages
    double totalLearning = 0, totalInfra = 0, totalGov = 0, totalOverall = 0;
    for (var s in scores) {
      totalLearning += s.learningOutcomes;
      totalInfra += s.infrastructure;
      totalGov += s.governanceProcess;
      totalOverall += s.totalScore;
    }
    
    int count = scores.length;
    double avgLearning = totalLearning / count;
    double avgInfra = totalInfra / count;
    double avgGov = totalGov / count;
    double avgOverall = totalOverall / count;
    
    // Create a dummy model to calculate the overall grade easily
    final avgModel = PgiScoreModel(
      districtId: 'AVG', stateId: stateName, year: 2026,
      learningOutcomes: avgLearning, access: 0, infrastructure: 0, equity: 0, governanceProcess: 0
    );

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
                Text(
                  '${avgOverall.toInt()} / 1000',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Grade: ${avgModel.grade}',
                    style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: avgOverall / 1000,
              backgroundColor: Colors.grey[200],
              color: Colors.deepPurple,
              minHeight: 10,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('Learning', '${avgLearning.toInt()}/180'),
                _buildMiniStat('Infrastructure', '${avgInfra.toInt()}/150'),
                _buildMiniStat('Governance', '${avgGov.toInt()}/360'),
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

  Widget _buildDistrictList(BuildContext context, List<PgiScoreModel> scores) {
    if (scores.isEmpty) {
      return const Text('No district data found.');
    }
    
    // Sort descending by total score
    scores.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final score = scores[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple[100],
              child: Text('${index + 1}'),
            ),
            title: Text(score.districtId, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Score: ${score.totalScore.toInt()} | Grade: ${score.grade}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PgiReportScreen(pgiScore: score)));
            },
          ),
        );
      },
    );
  }

  Widget _buildEscalationAction(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const EscalationDashboardScreen(userLevel: AdministrativeLevel.state)));
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
