import 'package:flutter/material.dart';
import 'package:shiksha_darpan/services/database_service.dart';
import 'package:shiksha_darpan/models/teacher_rating_model.dart';

class TeacherRatingsScreen extends StatelessWidget {
  const TeacherRatingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TeacherRatingModel>>(
      stream: DatabaseService().getTeacherRatings('mock_teacher_123'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No ratings yet.', style: TextStyle(fontSize: 18, color: Colors.grey)),
          );
        }

        final ratings = snapshot.data!;
        
        // Calculate average score
        double avgScore = 0;
        for (var r in ratings) {
          avgScore += r.totalScore;
        }
        avgScore /= ratings.length;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.indigo,
              width: double.infinity,
              child: Column(
                children: [
                  const Text(
                    'Overall Performance Score',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${avgScore.toStringAsFixed(1)} / 100',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Based on ${ratings.length} student/parent reviews',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ratings.length,
                itemBuilder: (context, index) {
                  final rating = ratings[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Score: ${rating.totalScore.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                '${rating.date.day}/${rating.date.month}/${rating.date.year}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const Divider(),
                          _buildRatingRow('Quality', rating.qualityScore),
                          _buildRatingRow('Punctuality', rating.punctualityScore),
                          _buildRatingRow('Fairness', rating.fairnessScore),
                          if (rating.comments != null && rating.comments!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '"${rating.comments}"',
                                style: const TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRatingRow(String label, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87)),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < score ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              );
            }),
          ),
        ],
      ),
    );
  }
}
