import 'package:hive/hive.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 0)
class DiaryEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String content;

  @HiveField(3)
  String mood;

  @HiveField(4)
  String? comment;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? updatedAt;

  DiaryEntry({
    required this.id,
    required this.date,
    required this.content,
    required this.mood,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  DiaryEntry copyWith({
    String? id,
    DateTime? date,
    String? content,
    String? mood,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Mood {
  final String id;
  final String emoji;
  final String label;
  final String labelKo;

  const Mood({
    required this.id,
    required this.emoji,
    required this.label,
    required this.labelKo,
  });

  static const List<Mood> moods = [
    Mood(id: 'happy', emoji: '😊', label: 'Happy', labelKo: '행복해'),
    Mood(id: 'sad', emoji: '😢', label: 'Sad', labelKo: '슬퍼'),
    Mood(id: 'angry', emoji: '😡', label: 'Angry', labelKo: '화나'),
    Mood(id: 'love', emoji: '🥰', label: 'Love', labelKo: '사랑해'),
    Mood(id: 'sleepy', emoji: '😴', label: 'Sleepy', labelKo: '졸려'),
    Mood(id: 'neutral', emoji: '😐', label: 'Neutral', labelKo: '그냥'),
  ];

  static Mood getMoodById(String id) {
    return moods.firstWhere(
      (mood) => mood.id == id,
      orElse: () => moods.last,
    );
  }
}
