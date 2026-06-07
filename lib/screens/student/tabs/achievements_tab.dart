import 'package:flutter/material.dart';
import 'package:shiksha_darpan/models/achievement_model.dart';
import 'package:shiksha_darpan/services/student_panel_service.dart';
import 'package:shiksha_darpan/theme/student_panel_theme.dart';

class AchievementsTab extends StatelessWidget {
  const AchievementsTab({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    final service = StudentPanelService();

    return StreamBuilder<List<AchievementModel>>(
      stream: service.streamAchievements(studentId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No achievements yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Awards from teachers will appear here.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final ach = items[index];
            final isLast = index == items.length - 1;
            return _TimelineCard(
              achievement: ach,
              showLine: !isLast,
            );
          },
        );
      },
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.achievement,
    required this.showLine,
  });

  final AchievementModel achievement;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${achievement.date.day}/${achievement.date.month}/${achievement.date.year}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: StudentPanelTheme.indigo,
                    shape: BoxShape.circle,
                  ),
                ),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: StudentPanelTheme.indigoLight,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              StudentPanelTheme.indigo.withValues(alpha: 0.12),
                          child: Icon(
                            achievement.category.icon,
                            color: StudentPanelTheme.indigo,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                achievement.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '${achievement.category.label} • $dateStr',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (achievement.photoUrl != null &&
                        achievement.photoUrl!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          achievement.photoUrl!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      achievement.description,
                      style: const TextStyle(height: 1.5),
                    ),
                    if (achievement.addedByTeacherName.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Added by ${achievement.addedByTeacherName}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
