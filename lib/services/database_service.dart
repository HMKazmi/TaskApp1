import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/models/subtask.dart';

class DatabaseService {
  final Box<Task> _taskBox = Hive.box<Task>('tasks');
  final Uuid _uuid = Uuid();

  // Get all tasks
  List<Task> getAllTasks() {
    return _taskBox.values.toList();
  }
  
  // Get tasks by filter
  List<Task> getTasksByFilter(TaskFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (filter) {
      case TaskFilter.all:
        return getAllTasks();
      case TaskFilter.today:
        return _taskBox.values.where((task) {
          final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
          return taskDate.isAtSameMomentAs(today);
        }).toList();
      case TaskFilter.upcoming:
        return _taskBox.values.where((task) {
          return !task.isCompleted && task.dueDate.isAfter(now);
        }).toList();
      case TaskFilter.completed:
        return _taskBox.values.where((task) => task.isCompleted).toList();
    }
  }
  
  // Add a new task
  Future<Task> addTask(
    String title,
    String description,
    DateTime dueDate,
    Priority priority,
    List<Subtask> subtasks,
    DateTime? reminderTime,
  ) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      subtasks: subtasks,
      reminderTime: reminderTime,
    );
    
    await _taskBox.put(task.id, task);
    return task;
  }
  
  // Update an existing task
  Future<void> updateTask(Task task) async {
    await _taskBox.put(task.id, task);
  }
  
  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _taskBox.delete(taskId);
  }
  
  // Mark task as complete or incomplete
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    final task = _taskBox.get(taskId);
    if (task != null) {
      task.isCompleted = isCompleted;
      await _taskBox.put(taskId, task);
    }
  }
  
  // Mark subtask as complete or incomplete
  Future<void> toggleSubtaskCompletion(String taskId, String subtaskId, bool isCompleted) async {
    final task = _taskBox.get(taskId);
    if (task != null) {
      final subtaskIndex = task.subtasks.indexWhere((subtask) => subtask.id == subtaskId);
      if (subtaskIndex != -1) {
        task.subtasks[subtaskIndex].isCompleted = isCompleted;
        await _taskBox.put(taskId, task);
      }
    }
  }
}

enum TaskFilter {
  all,
  today,
  upcoming,
  completed,
}

enum TaskSortOrder {
  dateAsc,
  dateDesc,
  priorityAsc,
  priorityDesc,
}
