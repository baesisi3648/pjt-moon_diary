import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/star_background.dart';
import '../widgets/comment_card.dart';
import 'write_diary_screen.dart';
import 'chat_diary_screen.dart';
import 'calendar_screen.dart';
import 'diary_list_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          CalendarScreen(),
          DiaryListScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 0 ? _buildFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, '홈'),
              _buildNavItem(
                  1, Icons.calendar_today_outlined, Icons.calendar_today, '캘린더'),
              const SizedBox(width: 56), // Space for FAB
              _buildNavItem(2, Icons.list_outlined, Icons.list, '목록'),
              _buildNavItem(
                  3, Icons.settings_outlined, Icons.settings, '설정'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.accentPurple : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? AppTheme.accentPurple : AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.purpleGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPurple.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          final provider = context.read<DiaryProvider>();
          provider.selectDate(DateTime.now());
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WriteDiaryScreen()),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.edit, color: Colors.white, size: 26),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiaryProvider>();
    final todayDiary = provider.getDiaryForDate(DateTime.now());
    final recentDiaries = provider.diaries.take(3).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/app_icon.png',
              width: 32,
              height: 32,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.nightlight_round,
                color: AppTheme.moonGlow,
                size: 28,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Moon Diary',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: StarBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                _buildGreeting(),
                const SizedBox(height: 24),

                // Today's diary status
                _buildTodayStatus(context, todayDiary),
                const SizedBox(height: 24),

                // Quick stats
                _buildQuickStats(provider),
                const SizedBox(height: 24),

                // Recent diaries
                if (recentDiaries.isNotEmpty) ...[
                  _buildSectionTitle('최근 일기'),
                  const SizedBox(height: 12),
                  ...recentDiaries.map((diary) => _buildRecentDiaryItem(
                        context,
                        diary,
                      )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;

    if (hour < 6) {
      greeting = '늦은 밤이에요';
      emoji = '🌙';
    } else if (hour < 12) {
      greeting = '좋은 아침이에요';
      emoji = '🌅';
    } else if (hour < 18) {
      greeting = '좋은 오후에요';
      emoji = '☀️';
    } else if (hour < 21) {
      greeting = '좋은 저녁이에요';
      emoji = '🌆';
    } else {
      greeting = '편안한 밤이에요';
      emoji = '🌙';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting $emoji',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(DateTime.now()),
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayStatus(BuildContext context, DiaryEntry? todayDiary) {
    if (todayDiary != null) {
      final mood = Mood.getMoodById(todayDiary.mood);
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.moodColors[todayDiary.mood]!.withValues(alpha: 0.2),
              AppTheme.cardDark.withValues(alpha: 0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.moodColors[todayDiary.mood]!.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(mood.emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '오늘의 일기를 작성했어요!',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '기분: ${mood.labelKo}',
                        style: TextStyle(
                          color: AppTheme.moodColors[todayDiary.mood],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.read<DiaryProvider>().selectDate(DateTime.now());
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WriteDiaryScreen(existingDiary: todayDiary),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            if (todayDiary.comment != null) ...[
              const SizedBox(height: 16),
              CommentCard(
                comment: todayDiary.comment!,
                mood: todayDiary.mood,
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.edit_note,
            color: AppTheme.accentPurple,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            '오늘의 일기를 작성해보세요',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '하루를 기록하고 따뜻한 코멘트를 받아보세요',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  context.read<DiaryProvider>().selectDate(DateTime.now());
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WriteDiaryScreen()),
                  );
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('직접 쓰기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cardDark,
                  foregroundColor: AppTheme.textPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatDiaryScreen()),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text('대화로 쓰기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(DiaryProvider provider) {
    final totalDiaries = provider.totalDiaries;
    final thisMonth = provider
        .getDiariesForMonth(DateTime.now().year, DateTime.now().month)
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '총 일기',
            '$totalDiaries',
            Icons.book_outlined,
            AppTheme.accentPurple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '이번 달',
            '$thisMonth',
            Icons.calendar_month,
            AppTheme.accentBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
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

  Widget _buildRecentDiaryItem(BuildContext context, DiaryEntry diary) {
    final mood = Mood.getMoodById(diary.mood);
    final moodColor = AppTheme.moodColors[diary.mood] ?? AppTheme.accentPurple;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.read<DiaryProvider>().selectDate(diary.date);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WriteDiaryScreen(existingDiary: diary),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardDark.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text(mood.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('M월 d일 (E)', 'ko_KR').format(diary.date),
                      style: TextStyle(
                        color: moodColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      diary.content,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
