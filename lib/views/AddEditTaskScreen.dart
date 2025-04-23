import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/database_service.dart';
import 'package:task_manager/services/notification_service.dart';
import 'package:task_manager/view_models/task_list_view_model.dart';
import 'package:task_manager/views/widgets/priority_selector.dart';

class AddEditTaskScreen extends StatefulWidget {
  final String? taskId;

  const AddEditTaskScreen({Key? key, this.taskId}) : super(key: key);

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  Priority _selectedPriority = Priority.medium;
  DateTime? _selectedReminderDateTime;
  final List<TextEditingController> _subtaskControllers = [];

  late TaskListViewModel _taskListViewModel;
  
  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _selectedTime = TimeOfDay.fromDateTime(now.add(const Duration(hours: 1)));

    // Initialize with one empty subtask
    _subtaskControllers.add(TextEditingController());

    // If editing an existing task, load its data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _taskListViewModel = Provider.of<TaskListViewModel>(context, listen: false);
      if (widget.taskId != null) {
        _loadTaskData();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _loadTaskData() {
    if (widget.taskId == null) return;

    final task = _taskListViewModel.getTaskById(widget.taskId!);

    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      _selectedTime = TimeOfDay.fromDateTime(task.dueDate);
      _selectedPriority = task.priority;
      _selectedReminderDateTime = task.reminderTime;

      // Clear the default empty subtask controller
      for (final controller in _subtaskControllers) {
        controller.dispose();
      }
      _subtaskControllers.clear();

      // Add controllers for existing subtasks
      for (final subtask in task.subtasks) {
        final controller = TextEditingController(text: subtask.title);
        _subtaskControllers.add(controller);
      }

      // Add one empty controller if there are no subtasks
      if (_subtaskControllers.isEmpty) {
        _subtaskControllers.add(TextEditingController());
      }

      setState(() {});
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectReminder(BuildContext context) async {
    // First select date
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedReminderDateTime ?? _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: _selectedDate,
    );

    if (pickedDate == null) return;

    // Then select time
    final pickedTime = await showTimePicker(
      context: context,
      initialTime:
          _selectedReminderDateTime != null
              ? TimeOfDay.fromDateTime(_selectedReminderDateTime!)
              : TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedReminderDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _addEmptySubtask() {
    setState(() {
      _subtaskControllers.add(TextEditingController());
    });
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtaskControllers[index].dispose();
      _subtaskControllers.removeAt(index);
    });
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    // Combine date and time
    final dueDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Filter out empty subtasks
    final subtaskTitles =
        _subtaskControllers
            .map((controller) => controller.text.trim())
            .toList(); // Allow empty subtasks to be saved
    
    if (widget.taskId == null) {
      // Create new task
      _taskListViewModel.addTask(
        _titleController.text,
        _descriptionController.text,
        dueDate,
        _selectedPriority,
        subtaskTitles,
        _selectedReminderDateTime,
      );
    } else {
      // Update existing task
      _taskListViewModel.updateTask(
        widget.taskId!,
        _titleController.text,
        _descriptionController.text,
        dueDate,
        _selectedPriority,
        subtaskTitles,
        _selectedReminderDateTime,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Time',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PrioritySelector(
              selectedPriority: _selectedPriority,
              onChanged: (priority) {
                setState(() {
                  _selectedPriority = priority;
                });
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectReminder(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Reminder',
                  border: const OutlineInputBorder(),
                  suffixIcon:
                      _selectedReminderDateTime != null
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedReminderDateTime = null;
                              });
                            },
                          )
                          : null,
                ),
                child: Text(
                  _selectedReminderDateTime != null
                      ? '${_selectedReminderDateTime!.day}/${_selectedReminderDateTime!.month}/${_selectedReminderDateTime!.year} '
                          '${TimeOfDay.fromDateTime(_selectedReminderDateTime!).format(context)}'
                      : 'No reminder set',
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtasks',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addEmptySubtask,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._buildSubtaskFields(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text(
                widget.taskId == null ? 'Add Task' : 'Update Task',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSubtaskFields() {
    return List.generate(
      _subtaskControllers.length,
      (index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _subtaskControllers[index],
                decoration: InputDecoration(
                  labelText: 'Subtask ${index + 1}',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeSubtask(index),
            ),
          ],
        ),
      ),
    );
  }
}