import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../services/diary_service.dart';
import '../services/comment_service.dart';

class DiaryProvider extends ChangeNotifier {
  final DiaryService _diaryService = DiaryService();
  
  List<DiaryEntry> _diaries = [];
  DiaryEntry? _selectedDiary;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  // Getters
  List<DiaryEntry> get diaries => _diaries;
  DiaryEntry? get selectedDiary => _selectedDiary;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalDiaries => _diaryService.totalDiaries;

  // Initialize
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _diaryService.init();
      _diaries = _diaryService.getAllDiaries();
      _error = null;
    } catch (e) {
      _error = '일기를 불러오는데 실패했어요';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Select date
  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedDiary = _diaryService.getDiaryForDate(date);
    notifyListeners();
  }

  // Create diary
  Future<DiaryEntry?> createDiary({
    required String content,
    required String mood,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Generate F감성 comment
      final comment = CommentService.generateComment(mood, content);
      
      final entry = await _diaryService.createDiary(
        date: _selectedDate,
        content: content,
        mood: mood,
        comment: comment,
      );

      _diaries = _diaryService.getAllDiaries();
      _selectedDiary = entry;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return entry;
    } catch (e) {
      _error = '일기 저장에 실패했어요';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update diary
  Future<DiaryEntry?> updateDiary({
    required DiaryEntry entry,
    String? content,
    String? mood,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newContent = content ?? entry.content;
      final newMood = mood ?? entry.mood;
      
      // Regenerate comment if content or mood changed
      String? newComment = entry.comment;
      if (content != null || mood != null) {
        newComment = CommentService.generateComment(newMood, newContent);
      }

      final updated = entry.copyWith(
        content: newContent,
        mood: newMood,
        comment: newComment,
        updatedAt: DateTime.now(),
      );

      final result = await _diaryService.updateDiary(updated);
      _diaries = _diaryService.getAllDiaries();
      _selectedDiary = result;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = '일기 수정에 실패했어요';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Delete diary
  Future<bool> deleteDiary(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _diaryService.deleteDiary(id);
      _diaries = _diaryService.getAllDiaries();
      if (_selectedDiary?.id == id) {
        _selectedDiary = null;
      }
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '일기 삭제에 실패했어요';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get diaries for month
  List<DiaryEntry> getDiariesForMonth(int year, int month) {
    return _diaryService.getDiariesByMonth(year, month);
  }

  // Get diary map for calendar
  Map<DateTime, List<DiaryEntry>> getDiaryMap() {
    return _diaryService.getDiaryMap();
  }

  // Check if diary exists for date
  bool hasDiaryForDate(DateTime date) {
    return _diaryService.hasDiaryForDate(date);
  }

  // Get mood statistics
  Map<String, int> getMoodStats() {
    return _diaryService.getMoodStats();
  }

  // Get diary for specific date
  DiaryEntry? getDiaryForDate(DateTime date) {
    return _diaryService.getDiaryForDate(date);
  }

  // Refresh diaries
  void refresh() {
    _diaries = _diaryService.getAllDiaries();
    notifyListeners();
  }
}
