import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CommentCard extends StatelessWidget {
  final String comment;
  final String? mood;

  const CommentCard({
    super.key,
    required this.comment,
    this.mood,
  });

  @override
  Widget build(BuildContext context) {
    final moodColor = mood != null
        ? AppTheme.moodColors[mood] ?? AppTheme.accentPurple
        : AppTheme.accentPurple;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            moodColor.withValues(alpha: 0.15),
            AppTheme.accentBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: moodColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: moodColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 코멘트',
                style: TextStyle(
                  color: moodColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
