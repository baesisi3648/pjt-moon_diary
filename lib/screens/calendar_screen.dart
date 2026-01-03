import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/star_background.dart';
import 'write_diary_screen.dart';
import 'diary_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiaryProvider>();
    final diaryMap = provider.getDiaryMap();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('캘린더'),
      ),
      body: StarBackground(
        showMoon: false,
        child: SafeArea(
          child: Column(
            children: [
              // Calendar
              _buildCalendar(diaryMap),
              const SizedBox(height: 16),
              // Selected day's diary
              Expanded(
                child: _buildSelectedDayDiary(provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(Map<DateTime, List<DiaryEntry>> diaryMap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TableCalendar<DiaryEntry>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        locale: 'ko_KR',
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: (day) {
          final normalizedDay = DateTime(day.year, day.month, day.day);
          return diaryMap[normalizedDay] ?? [];
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          context.read<DiaryProvider>().selectDate(selectedDay);
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          defaultTextStyle: const TextStyle(color: AppTheme.textPrimary),
          weekendTextStyle: const TextStyle(color: AppTheme.textSecondary),
          outsideTextStyle: TextStyle(
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          selectedDecoration: const BoxDecoration(
            color: AppTheme.accentPurple,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.accentBlue.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppTheme.starYellow,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
          markerSize: 6,
          markerMargin: const EdgeInsets.symmetric(horizontal: 1),
        ),
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppTheme.textPrimary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppTheme.textPrimary,
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          weekendStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return null;
            final diary = events.first;
            final mood = Mood.getMoodById(diary.mood);
            return Positioned(
              bottom: 1,
              child: Text(
                mood.emoji,
                style: const TextStyle(fontSize: 12),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedDayDiary(DiaryProvider provider) {
    if (_selectedDay == null) return const SizedBox.shrink();

    final diary = provider.getDiaryForDate(_selectedDay!);
    final isToday = isSameDay(_selectedDay, DateTime.now());
    final isFuture = _selectedDay!.isAfter(DateTime.now());

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: diary != null
          ? _buildDiaryPreview(diary)
          : _buildNoDiaryMessage(isToday, isFuture),
    );
  }

  Widget _buildDiaryPreview(DiaryEntry diary) {
    final mood = Mood.getMoodById(diary.mood);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DiaryDetailScreen(diary: diary),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                mood.emoji,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('yyyy년 M월 d일').format(diary.date),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      mood.labelKo,
                      style: TextStyle(
                        color: AppTheme.moodColors[diary.mood],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              diary.content,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
                height: 1.6,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDiaryMessage(bool isToday, bool isFuture) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFuture ? Icons.hourglass_empty : Icons.edit_note,
            color: AppTheme.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            isFuture
                ? '아직 오지 않은 날이에요'
                : isToday
                    ? '오늘의 일기를 작성해보세요!'
                    : '이 날의 일기가 없어요',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          if (!isFuture) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<DiaryProvider>().selectDate(_selectedDay!);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WriteDiaryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.edit, size: 18),
              label: Text(isToday ? '일기 쓰기' : '일기 추가하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
