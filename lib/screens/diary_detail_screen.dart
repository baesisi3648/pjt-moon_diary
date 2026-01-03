import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/star_background.dart';
import '../widgets/comment_card.dart';
import 'write_diary_screen.dart';

class DiaryDetailScreen extends StatelessWidget {
  final DiaryEntry diary;

  const DiaryDetailScreen({
    super.key,
    required this.diary,
  });

  @override
  Widget build(BuildContext context) {
    final mood = Mood.getMoodById(diary.mood);
    final moodColor = AppTheme.moodColors[diary.mood] ?? AppTheme.accentPurple;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              context.read<DiaryProvider>().selectDate(diary.date);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => WriteDiaryScreen(existingDiary: diary),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: StarBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and mood header
                _buildHeader(mood, moodColor),
                const SizedBox(height: 24),

                // Diary content
                _buildContent(),
                const SizedBox(height: 24),

                // Comment
                if (diary.comment != null) ...[
                  CommentCard(
                    comment: diary.comment!,
                    mood: diary.mood,
                  ),
                  const SizedBox(height: 24),
                ],

                // Metadata
                _buildMetadata(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Mood mood, Color moodColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            moodColor.withValues(alpha: 0.2),
            AppTheme.cardDark.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: moodColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: moodColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              mood.emoji,
              style: const TextStyle(fontSize: 40),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('yyyy년 M월 d일').format(diary.date),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE', 'ko_KR').format(diary.date),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: moodColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    mood.labelKo,
                    style: TextStyle(
                      color: moodColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        diary.content,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 17,
          height: 1.8,
        ),
      ),
    );
  }

  Widget _buildMetadata() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildMetadataRow(
            Icons.access_time,
            '작성',
            DateFormat('yyyy.MM.dd HH:mm').format(diary.createdAt),
          ),
          if (diary.updatedAt != null) ...[
            const SizedBox(height: 8),
            _buildMetadataRow(
              Icons.edit,
              '수정',
              DateFormat('yyyy.MM.dd HH:mm').format(diary.updatedAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '일기 삭제',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          '정말 이 일기를 삭제할까요?\n삭제된 일기는 복구할 수 없어요.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<DiaryProvider>().deleteDiary(diary.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('일기가 삭제되었어요'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.cardDark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
