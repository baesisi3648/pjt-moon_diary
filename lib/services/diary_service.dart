import 'package:hive_flutter/hive_flutter.dart';
import '../models/diary_entry.dart';

class DiaryService {
  static const String _boxName = 'diaries';
  late Box<DiaryEntry> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DiaryEntryAdapter());
    _box = await Hive.openBox<DiaryEntry>(_boxName);
  }

  // Create
  Future<DiaryEntry> createDiary({
    required DateTime date,
    required String content,
    required String mood,
    String? comment,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final entry = DiaryEntry(
      id: id,
      date: date,
      content: content,
      mood: mood,
      comment: comment,
      createdAt: DateTime.now(),
    );
    await _box.put(id, entry);
    return entry;
  }

  // Read
  DiaryEntry? getDiary(String id) {
    return _box.get(id);
  }

  List<DiaryEntry> getAllDiaries() {
    return _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<DiaryEntry> getDiariesByDate(DateTime date) {
    return _box.values.where((entry) {
      return entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day;
    }).toList();
  }

  List<DiaryEntry> getDiariesByMonth(int year, int month) {
    return _box.values.where((entry) {
      return entry.date.year == year && entry.date.month == month;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  DiaryEntry? getDiaryForDate(DateTime date) {
    try {
      return _box.values.firstWhere((entry) {
        return entry.date.year == date.year &&
            entry.date.month == date.month &&
            entry.date.day == date.day;
      });
    } catch (e) {
      return null;
    }
  }

  // Update
  Future<DiaryEntry> updateDiary(DiaryEntry entry) async {
    final updated = entry.copyWith(updatedAt: DateTime.now());
    await _box.put(entry.id, updated);
    return updated;
  }

  // Delete
  Future<void> deleteDiary(String id) async {
    await _box.delete(id);
  }

  // Get diary dates for calendar
  Map<DateTime, List<DiaryEntry>> getDiaryMap() {
    final map = <DateTime, List<DiaryEntry>>{};
    for (final entry in _box.values) {
      final normalizedDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      if (map.containsKey(normalizedDate)) {
        map[normalizedDate]!.add(entry);
      } else {
        map[normalizedDate] = [entry];
      }
    }
    return map;
  }

  // Check if diary exists for date
  bool hasDiaryForDate(DateTime date) {
    return _box.values.any((entry) {
      return entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day;
    });
  }

  // Get statistics
  Map<String, int> getMoodStats() {
    final stats = <String, int>{};
    for (final entry in _box.values) {
      stats[entry.mood] = (stats[entry.mood] ?? 0) + 1;
    }
    return stats;
  }

  int get totalDiaries => _box.length;
}
