import 'package:flutter/material.dart';
import 'package:task_manager/models/subtask.dart';

class SubtaskListItem extends StatelessWidget {
  final Subtask subtask;
  final Function(bool) onToggleCompletion;
  
  const SubtaskListItem({
    Key? key,
    required this.subtask,
    required this.onToggleCompletion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: subtask.isCompleted,
        onChanged: (value) {
          if (value != null) {
            onToggleCompletion(value);
          }
        },
      ),
      title: Text(
        subtask.title,
        style: TextStyle(
          decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
          color: subtask.isCompleted ? Colors.grey : null,
        ),
      ),
    );
  }
}
