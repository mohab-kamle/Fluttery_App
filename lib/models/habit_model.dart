import 'package:hive/hive.dart';
part 'habit_model.g.dart';

@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime time;

  @HiveField(3)
  bool reminderEnabled;

  @HiveField(4)
  int streak;

  @HiveField(5)
  DateTime? lastCompletedDate;

  Habit({
    required this.id,
    required this.title,
    required this.time,
    this.reminderEnabled = false,
    this.streak = 0,
    this.lastCompletedDate,
  });
}
