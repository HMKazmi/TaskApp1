import 'package:flutter/material.dart';
import 'package:task_manager/models/task.dart';

class PrioritySelector extends StatelessWidget {
  final Priority selectedPriority;
  final Function(Priority) onChanged;
  
  const PrioritySelector({
    Key? key,
    required this.selectedPriority,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildPriorityOption(
              context,
              Priority.low,
              'Low',
              Colors.green,
            ),
            const SizedBox(width: 16),
            _buildPriorityOption(
              context,
              Priority.medium,
              'Medium',
              Colors.orange,
            ),
            const SizedBox(width: 16),
            _buildPriorityOption(
              context,
              Priority.high,
              'High',
              Colors.red,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildPriorityOption(
    BuildContext context,
    Priority priority,
    String label,
    Color color,
  ) {
    final isSelected = selectedPriority == priority;
    
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(priority),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.grey,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                _getPriorityIcon(priority),
                color: isSelected ? color : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Icons.arrow_downward;
      case Priority.medium:
        return Icons.remove;
      case Priority.high:
        return Icons.arrow_upward;
    }
  }
}