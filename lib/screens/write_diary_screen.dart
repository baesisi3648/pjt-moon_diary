import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/star_background.dart';
import '../widgets/mood_selector.dart';
import '../widgets/comment_card.dart';

class WriteDiaryScreen extends StatefulWidget {
  final DiaryEntry? existingDiary;

  const WriteDiaryScreen({
    super.key,
    this.existingDiary,
  });

  @override
  State<WriteDiaryScreen> createState() => _WriteDiaryScreenState();
}

class _WriteDiaryScreenState extends State<WriteDiaryScreen> {
  late TextEditingController _contentController;
  String? _selectedMood;
  bool _isSaving = false;
  DiaryEntry? _savedDiary;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.existingDiary?.content ?? '',
    );
    _selectedMood = widget.existingDiary?.mood;
    _savedDiary = widget.existingDiary;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveDiary() async {
    if (_selectedMood == null) {
      _showSnackBar('기분을 선택해주세요!');
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      _showSnackBar('일기를 작성해주세요!');
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<DiaryProvider>();
    DiaryEntry? result;

    if (widget.existingDiary != null) {
      result = await provider.updateDiary(
        entry: widget.existingDiary!,
        content: _contentController.text.trim(),
        mood: _selectedMood,
      );
    } else {
      result = await provider.createDiary(
        content: _contentController.text.trim(),
        mood: _selectedMood!,
      );
    }

    setState(() {
      _isSaving = false;
      _savedDiary = result;
    });

    if (result != null) {
      _showSnackBar('일기가 저장되었어요! 💫');
    } else {
      _showSnackBar('저장에 실패했어요. 다시 시도해주세요.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiaryProvider>();
    final selectedDate = provider.selectedDate;
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isToday ? '오늘의 일기' : DateFormat('M월 d일').format(selectedDate),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (widget.existingDiary != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
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
                // Date display
                _buildDateHeader(selectedDate),
                const SizedBox(height: 24),

                // Mood selector
                MoodSelector(
                  selectedMood: _selectedMood,
                  onMoodSelected: (mood) {
                    setState(() => _selectedMood = mood);
                  },
                ),
                const SizedBox(height: 24),

                // Diary content input
                _buildDiaryInput(),
                const SizedBox(height: 24),

                // Save button
                _buildSaveButton(),
                const SizedBox(height: 24),

                // Comment card (shown after saving)
                if (_savedDiary?.comment != null) ...[
                  CommentCard(
                    comment: _savedDiary!.comment!,
                    mood: _savedDiary!.mood,
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            color: AppTheme.accentPurple,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('yyyy년 M월 d일').format(date),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                DateFormat('EEEE', 'ko_KR').format(date),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _contentController,
        maxLines: 10,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 16,
          height: 1.8,
        ),
        decoration: InputDecoration(
          hintText: '오늘 하루는 어땠나요?\n자유롭게 적어보세요...',
          hintStyle: TextStyle(
            color: AppTheme.textSecondary.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveDiary,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save_alt, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    widget.existingDiary != null ? '수정하기' : '저장하기',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<DiaryProvider>();
              await provider.deleteDiary(widget.existingDiary!.id);
              if (mounted) {
                Navigator.pop(context);
                _showSnackBar('일기가 삭제되었어요');
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
