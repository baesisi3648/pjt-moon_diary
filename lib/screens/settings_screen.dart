import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/star_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final diaryProvider = context.watch<DiaryProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('설정'),
      ),
      body: StarBackground(
        showMoon: false,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats section
                _buildStatsSection(diaryProvider),
                const SizedBox(height: 24),

                // Theme section
                _buildSectionTitle('테마'),
                const SizedBox(height: 12),
                _buildThemeToggle(themeProvider),
                const SizedBox(height: 24),

                // Mood statistics
                _buildSectionTitle('기분 통계'),
                const SizedBox(height: 12),
                _buildMoodStats(diaryProvider),
                const SizedBox(height: 24),

                // App info
                _buildSectionTitle('앱 정보'),
                const SizedBox(height: 12),
                _buildAppInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatsSection(DiaryProvider provider) {
    final totalDiaries = provider.totalDiaries;
    final moodStats = provider.getMoodStats();
    final mostFrequentMood = moodStats.entries.isEmpty
        ? null
        : moodStats.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentPurple.withValues(alpha: 0.2),
            AppTheme.accentBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '총 일기',
                '$totalDiaries',
                Icons.book_outlined,
              ),
              _buildStatItem(
                '이번 달',
                '${_getThisMonthCount(provider)}',
                Icons.calendar_month,
              ),
              _buildStatItem(
                '자주 느끼는 기분',
                mostFrequentMood != null
                    ? Mood.getMoodById(mostFrequentMood).emoji
                    : '📝',
                Icons.emoji_emotions_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getThisMonthCount(DiaryProvider provider) {
    final now = DateTime.now();
    return provider.getDiariesForMonth(now.year, now.month).length;
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accentPurple, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeToggle(ThemeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppTheme.accentPurple,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '다크 모드',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  provider.isDarkMode ? '밤하늘 테마가 적용 중' : '밝은 테마가 적용 중',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: provider.isDarkMode,
            onChanged: (_) => provider.toggleTheme(),
            activeColor: AppTheme.accentPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodStats(DiaryProvider provider) {
    final moodStats = provider.getMoodStats();
    final totalCount =
        moodStats.values.fold<int>(0, (sum, count) => sum + count);

    if (totalCount == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardDark.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            '일기를 작성하면 기분 통계를 볼 수 있어요',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: Mood.moods.map((mood) {
          final count = moodStats[mood.id] ?? 0;
          final percentage = totalCount > 0 ? count / totalCount : 0.0;
          final moodColor =
              AppTheme.moodColors[mood.id] ?? AppTheme.textSecondary;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(mood.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            mood.labelKo,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '$count회 (${(percentage * 100).toStringAsFixed(0)}%)',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor:
                              AppTheme.textSecondary.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(moodColor),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow('앱 이름', 'Moon Diary'),
          const Divider(color: AppTheme.textSecondary, height: 24),
          _buildInfoRow('버전', '1.0.0'),
          const Divider(color: AppTheme.textSecondary, height: 24),
          _buildInfoRow('개발', 'Made with 💜'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
