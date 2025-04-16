import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/database_service.dart';
import 'package:task_manager/view_models/task_list_view_model.dart';
import 'package:task_manager/views/add_edit_task_screen.dart';
import 'package:task_manager/views/task_detail_screen.dart';
import 'package:task_manager/views/widgets/task_list_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          PopupMenuButton<TaskSortOrder>(
            icon: const Icon(Icons.sort),
            onSelected: (order) {
              Provider.of<TaskListViewModel>(context, listen: false)
                  .setSortOrder(order);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TaskSortOrder.dateAsc,
                child: Text('Date (Oldest first)'),
              ),
              const PopupMenuItem(
                value: TaskSortOrder.dateDesc,
                child: Text('Date (Newest first)'),
              ),
              const PopupMenuItem(
                value: TaskSortOrder.priorityDesc,
                child: Text('Priority (High to Low)'),
              ),
              const PopupMenuItem(
                value: TaskSortOrder.priorityAsc,
                child: Text('Priority (Low to High)'),
              ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Consumer<TaskListViewModel>(
        builder: (context, viewModel, child) {
          final tasks = viewModel.tasks;
          
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.task_alt, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a task to get started',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Dismissible(
                key: Key(task.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Task'),
                      content: const Text('Are you sure you want to delete this task?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('DELETE'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  viewModel.deleteTask(task.id);
                },
                child: TaskListItem(
                  task: task,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailScreen(taskId: task.id),
                      ),
                    );
                  },
                  onToggleCompletion: (isCompleted) {
                    viewModel.toggleTaskCompletion(task.id, isCompleted);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildDrawer(BuildContext context) {
    final viewModel = Provider.of<TaskListViewModel>(context);
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'Task Manager',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('All Tasks'),
            selected: viewModel.currentFilter == TaskFilter.all,
            onTap: () {
              viewModel.setFilter(TaskFilter.all);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.today),
            title: const Text('Today'),
            selected: viewModel.currentFilter == TaskFilter.today,
            onTap: () {
              viewModel.setFilter(TaskFilter.today);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Upcoming'),
            selected: viewModel.currentFilter == TaskFilter.upcoming,
            onTap: () {
              viewModel.setFilter(TaskFilter.upcoming);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('Completed'),
            selected: viewModel.currentFilter == TaskFilter.completed,
            onTap: () {
              viewModel.setFilter(TaskFilter.completed);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
