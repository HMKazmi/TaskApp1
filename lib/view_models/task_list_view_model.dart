import 'package:flutter/foundation.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/models/subtask.dart';
import 'package:task_manager/services/database_service.dart';
import 'package:task_manager/services/notification_service.dart';
import 'package:uuid/uuid.dart';

class TaskListViewModel extends ChangeNotifier {
  final DatabaseService databaseService;
  final NotificationService notificationService;
  final Uuid _uuid = Uuid();
  
  List<Task> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  TaskSortOrder _sortOrder = TaskSortOrder.dateAsc;
  
  List<Task> get tasks => _sortTasks(_tasks);
  TaskFilter get currentFilter => _currentFilter;
  TaskSortOrder get sortOrder => _sortOrder;
  
  TaskListViewModel({
    required this.databaseService,
    required this.notificationService,
  }) {
    _loadTasks();
  }
  
  Future<void> _loadTasks() async {
    _tasks = databaseService.getTasksByFilter(_currentFilter);
    notifyListeners();
  }
  
  List<Task> _sortTasks(List<Task> tasks) {
    final sortedTasks = List<Task>.from(tasks);
    
    switch (_sortOrder) {
      case TaskSortOrder.dateAsc:
        sortedTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case TaskSortOrder.dateDesc:
        sortedTasks.sort((a, b) => b.dueDate.compareTo(a.dueDate));
        break;
      case TaskSortOrder.priorityAsc:
        sortedTasks.sort((a, b) => a.priority.index.compareTo(b.priority.index));
        break;
      case TaskSortOrder.priorityDesc:
        sortedTasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
    }
    
    return sortedTasks;
  }
  
  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    _loadTasks();
  }
  
  void setSortOrder(TaskSortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }
  
  Future<void> addTask(
    String title,
    String description,
    DateTime dueDate,
    Priority priority,
    List<String> subtaskTitles,
    DateTime? reminderTime,
  ) async {
    // Create subtasks from titles
    final subtasks = subtaskTitles.map((title) => Subtask(
      id: _uuid.v4(),
      title: title,
    )).toList();
    
    // Add the task
    final task = await databaseService.addTask(
      title, 
      description, 
      dueDate, 
      priority, 
      subtasks, 
      reminderTime,
    );
    
    // Schedule notification if reminder time is set
    if (reminderTime != null) {
      await notificationService.scheduleTaskReminder(task);
    }
    
    // Reload tasks
    _loadTasks();
  }
  
  Future<void> updateTask(Task task) async {
    await databaseService.updateTask(task);
    
    // Update or cancel notification
    if (task.reminderTime != null) {
      await notificationService.scheduleTaskReminder(task);
    } else {
      await notificationService.cancelTaskReminder(task.id);
    }
    
    _loadTasks();
  }
  
  Future<void> deleteTask(String taskId) async {
    await databaseService.deleteTask(taskId);
    await notificationService.cancelTaskReminder(taskId);
    _loadTasks();
  }
  
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    await databaseService.toggleTaskCompletion(taskId, isCompleted);
    
    // If task is marked as completed, cancel its reminder
    if (isCompleted) {
      await notificationService.cancelTaskReminder(taskId);
    }
    
    _loadTasks();
  }
  
  Future<void> toggleSubtaskCompletion(String taskId, String subtaskId, bool isCompleted) async {
    await databaseService.toggleSubtaskCompletion(taskId, subtaskId, isCompleted);
    _loadTasks();
  }
}
