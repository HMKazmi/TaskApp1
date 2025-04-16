import 'package:flutter/material.dart';
import 'package:task_manager/models/task.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final Function(bool) onToggleCompletion;
  
  const TaskListItem({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onToggleCompletion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      if (value != null) {
                        onToggleCompletion(value);
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted ? Colors.grey : null,
                      ),
                    ),
                  ),
                  _buildPriorityIndicator(task.priority),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 40),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                    style: TextStyle(
                      color: task.isOverdue ? Colors.red : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (task.reminderTime != null) ...[
                    Icon(
                      Icons.notifications,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Reminder set',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (task.subtasks.isNotEmpty) ...[
                    const Spacer(),
                    Text(
                      '${task.subtasks.where((s) => s.isCompleted).length}/${task.subtasks.length}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              if (task.subtasks.isNotEmpty) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: task.completionPercentage,
                  backgroundColor: Colors.grey[300],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPriorityIndicator(Priority priority) {
    Color color;
    String label;
    
    switch (priority) {
      case Priority.low:
        color = Colors.green;
        label = 'Low';
        break;
      case Priority.medium:
        color = Colors.orange;
        label = 'Medium';
        break;
      case Priority.high:
        color = Colors.red;
        label = 'High';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
