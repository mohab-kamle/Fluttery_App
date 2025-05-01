import 'package:hive/hive.dart';

part 'task_model.g.dart'; // Required for code generation

@HiveType(typeId: 0) // Assign a unique typeId for this model
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String time;

  @HiveField(4)
  String priority;

  @HiveField(5)
  String? userId;

  @HiveField(6)
  bool? done;

  Task({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.priority,
    this.userId,
    this.done = false,
  });
}
