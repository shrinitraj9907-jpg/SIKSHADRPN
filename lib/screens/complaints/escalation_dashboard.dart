import 'package:flutter/material.dart';
import 'package:shiksha_darpan/models/complaint_model.dart';
import 'package:shiksha_darpan/models/user_model.dart';
import 'package:shiksha_darpan/services/database_service.dart';

class EscalationDashboardScreen extends StatefulWidget {
  final AdministrativeLevel userLevel; 

  const EscalationDashboardScreen({
    Key? key, 
    this.userLevel = AdministrativeLevel.intermediate,
  }) : super(key: key);

  @override
  State<EscalationDashboardScreen> createState() => _EscalationDashboardScreenState();
}

class _EscalationDashboardScreenState extends State<EscalationDashboardScreen> {
  final DatabaseService _dbService = DatabaseService();

  String _getLevelName(AdministrativeLevel level) {
    switch (level) {
      case AdministrativeLevel.ground: return "Ground Level";
      case AdministrativeLevel.intermediate: return "Intermediate (District)";
      case AdministrativeLevel.state: return "State Level";
      case AdministrativeLevel.national: return "National Level";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escalation Inbox'),
        backgroundColor: Colors.red[900],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Dev tool to simulate a daily cron job
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Running Auto-Escalation Job...')),
          );
          try {
            await _dbService.runAutoEscalationJob();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Job Completed Successfully')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        },
        backgroundColor: Colors.red[900],
        tooltip: 'Run Auto-Escalation (Dev)',
        child: const Icon(Icons.bolt),
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
                    'Viewing complaints auto-escalated to ${_getLevelName(widget.userLevel)} because they exceeded the SLA at the lower level.',
                    style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ComplaintModel>>(
              stream: _dbService.getEscalatedComplaints(widget.userLevel),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final complaints = snapshot.data ?? [];
                
                if (complaints.isEmpty) {
                  return const Center(
                    child: Text('No escalated complaints found.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    final daysSinceSubmission = DateTime.now().difference(complaint.submittedDate).inDays;

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
                                  label: Text(
                                    complaint.isAnonymous ? 'Anonymous' : 'User ID: ${complaint.submitterId ?? "Unknown"}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12)
                                  ),
                                  backgroundColor: Colors.grey[800],
                                ),
                                Text(
                                  'Submitted: $daysSinceSubmission days ago',
                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              complaint.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(complaint.description, style: const TextStyle(color: Colors.black87)),
                            const SizedBox(height: 8),
                            Text('School UDISE: ${complaint.schoolUdiseCode}', style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    // TODO: Implement view evidence
                                  },
                                  icon: const Icon(Icons.remove_red_eye),
                                  label: const Text('View Evidence'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () async {
                                    // Mark as resolved (mock action)
                                    await _dbService.updateComplaintStatus(
                                      complaint.id, 
                                      ComplaintStatus.resolved, 
                                      null
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800], foregroundColor: Colors.white),
                                  child: const Text('Resolve Action'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
