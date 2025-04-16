import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/models/task.dart';
// import 'package:task_manager/services/database_service.dart';
// import 'package:task_manager/services/notification_service.dart';
import 'package:task_manager/view_models/task_detail_view_model.dart';
import 'package:task_manager/view_models/task_list_view_model.dart';
import 'package:task_manager/views/add_edit_task_screen.dart';
import 'package:task_manager/views/widgets/subtask_list_item.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;
  
  const TaskDetailScreen({
    Key? key,
    required this.taskId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskDetailViewModel(
        databaseService: Provider.of<TaskListViewModel>(context, listen: false).databaseService,
        notificationService: Provider.of<TaskListViewModel>(context, listen: false).notificationService,
        taskId: taskId,
      ),
      child: Consumer<TaskDetailViewModel>(
        builder: (context, viewModel, child) {
          final task = viewModel.task;
          
          if (task == null) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          return Scaffold(
            appBar: AppBar(
              title: Text(task.title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditTaskScreen(taskId: task.id),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Task completion status
                Row(
                  children: [
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.toggleTaskCompletion(value);
                        }
                      },
                    ),
                    Text(
                      task.isCompleted ? 'Completed' : 'Mark as completed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: task.isCompleted ? Colors.green : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Task details
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          context,
                          'Priority',
                          _getPriorityString(task.priority),
                          _getPriorityIcon(task.priority),
                        ),
                        const Divider(),
                        _buildDetailRow(
                          context,
                          'Due date',
                          '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                          Icons.calendar_today,
                        ),
                        const Divider(),
                        _buildDetailRow(
                          context,
                          'Due time',
                          TimeOfDay.fromDateTime(task.dueDate).format(context),
                          Icons.access_time,
                        ),
                        if (task.reminderTime != null) ...[
                          const Divider(),
                          _buildDetailRow(
                            context,
                            'Reminder',
                            '${task.reminderTime!.day}/${task.reminderTime!.month}/${task.reminderTime!.year} '
                                '${TimeOfDay.fromDateTime(task.reminderTime!).format(context)}',
                            Icons.notifications,
                          ),
                        ],
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          task.description.isEmpty
                              ? 'No description'
                              : task.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Subtasks
                Text(
                  'Subtasks',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (task.subtasks.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No subtasks'),
                    ),
                  )
                else
                  Card(
                    elevation: 2,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: task.subtasks.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final subtask = task.subtasks[index];
                        return SubtaskListItem(
                          subtask: subtask,
                          onToggleCompletion: (isCompleted) {
                            viewModel.toggleSubtaskCompletion(
                              subtask.id,
                              isCompleted,
                            );
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                
                // Add subtask button
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddSubtaskDialog(context, viewModel);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Subtask'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  String _getPriorityString(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }
  
  IconData _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Icons.low_priority;
      case Priority.medium:
        return Icons.flag;
      case Priority.high:
        return Icons.priority_high;
    }
  }
  
  void _showAddSubtaskDialog(BuildContext context, TaskDetailViewModel viewModel) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subtask'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Subtask title',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                viewModel.addSubtask(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }
}
