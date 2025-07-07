import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 3)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  bool hasReminder;

  @HiveField(5)
  String? linkedCaseId; // Optional

  @HiveField(6)
  bool isCompleted; // ✅ Add this if not done


  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.hasReminder = false,
    this.linkedCaseId,
    required this.isCompleted
  });
}
