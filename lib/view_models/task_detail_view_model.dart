import 'package:flutter/foundation.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/models/subtask.dart';
import 'package:task_manager/services/database_service.dart';
import 'package:task_manager/services/notification_service.dart';
import 'package:uuid/uuid.dart';

class TaskDetailViewModel extends ChangeNotifier {
  final DatabaseService databaseService;
  final NotificationService notificationService;
  final String taskId;
  
  Task? _task;
  Task? get task => _task;
  
  final Uuid _uuid = Uuid();
  
  TaskDetailViewModel({
    required this.databaseService,
    required this.notificationService,
    required this.taskId,
  }) {
    _loadTask();
  }
  
  Future<void> _loadTask() async {
    _task = databaseService.getAllTasks().firstWhere((task) => task.id == taskId);
    notifyListeners();
  }
  
  Future<void> toggleTaskCompletion(bool isCompleted) async {
    if (_task == null) return;
    
    await databaseService.toggleTaskCompletion(_task!.id, isCompleted);
    
    // If marked as completed, cancel the reminder
    if (isCompleted) {
      await notificationService.cancelTaskReminder(_task!.id);
    } else if (_task!.reminderTime != null && _task!.reminderTime!.isAfter(DateTime.now())) {
      // If marked as not completed and there's a future reminder, reschedule it
      await notificationService.scheduleTaskReminder(_task!);
    }
    
    await _loadTask();
  }
  
  Future<void> toggleSubtaskCompletion(String subtaskId, bool isCompleted) async {
    if (_task == null) return;
    
    await databaseService.toggleSubtaskCompletion(_task!.id, subtaskId, isCompleted);
    await _loadTask();
  }
  
  Future<void> addSubtask(String title) async {
    if (_task == null) return;
    
    final subtask = Subtask(
      id: _uuid.v4(),
      title: title,
    );
    
    _task!.subtasks.add(subtask);
    await databaseService.updateTask(_task!);
    await _loadTask();
  }
  
  Future<void> deleteSubtask(String subtaskId) async {
    if (_task == null) return;
    
    _task!.subtasks.removeWhere((subtask) => subtask.id == subtaskId);
    await databaseService.updateTask(_task!);
    await _loadTask();
  }
  
  Future<void> updateTask({
    String? title,
    String? description,
    DateTime? dueDate,
    Priority? priority,
    DateTime? reminderTime,
  }) async {
    if (_task == null) return;
    
    if (title != null) _task!.title = title;
    if (description != null) _task!.description = description;
    if (dueDate != null) _task!.dueDate = dueDate;
    if (priority != null) _task!.priority = priority;
    
    // Handle reminder changes
    if (reminderTime != _task!.reminderTime) {
      _task!.reminderTime = reminderTime;
      
      if (reminderTime == null) {
        await notificationService.cancelTaskReminder(_task!.id);
      } else {
        await notificationService.scheduleTaskReminder(_task!);
      }
    }
    
    await databaseService.updateTask(_task!);
    await _loadTask();
  }
}