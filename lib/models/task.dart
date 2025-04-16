import 'package:hive/hive.dart';
import 'package:task_manager/models/subtask.dart';
part 'task.g.dart'; // Will be generated with Hive code generator

@HiveType(typeId: 0)
enum Priority {
  @HiveField(0)
  low,
  
  @HiveField(1)
  medium,
  
  @HiveField(2)
  high,
}

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  DateTime dueDate;
  
  @HiveField(4)
  Priority priority;
  
  @HiveField(5)
  bool isCompleted;
  
  @HiveField(6)
  List<Subtask> subtasks;
  
  @HiveField(7)
  DateTime? reminderTime;
  
  @HiveField(8)
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    List<Subtask>? subtasks,
    this.reminderTime,
    DateTime? createdAt,
  }) : 
    this.subtasks = subtasks ?? [],
    this.createdAt = createdAt ?? DateTime.now();

  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());
  
  bool get isForToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return taskDate.isAtSameMomentAs(today);
  }
  
  double get completionPercentage {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completedSubtasks = subtasks.where((subtask) => subtask.isCompleted).length;
    return completedSubtasks / subtasks.length;
  }
}
