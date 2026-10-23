import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../screens/todo_form_screen.dart';
import '../state/todo_state.dart';
import '../utils/date_format.dart';

class TodoTile extends StatelessWidget {
  const TodoTile({super.key, required this.todo, required this.state});
  final Todo todo;
  final TodoState state;

  Future<void> _edit(BuildContext context) async {
    final result = await Navigator.push<TodoFormResult>(
      context,
      MaterialPageRoute(builder: (_) => TodoFormScreen(todo: todo)),
    );
    if (result != null) {
      state.update(todo.copyWith(
        title: result.title,
        priority: result.priority,
        dueDate: result.dueDate,
        clearDueDate: result.dueDate == null, // срок убрали в форме
      ));
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить задачу?'),
        content: Text('«${todo.title}» будет удалена без возможности восстановления.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => state.delete(todo.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        child: ListTile(
          onTap: () => _edit(context),
          leading: Checkbox(
            value: todo.isDone,
            onChanged: (_) => state.toggleDone(todo),
          ),
          title: Text(
            todo.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              decoration: todo.isDone ? TextDecoration.lineThrough : null,
              color: todo.isDone ? Colors.grey : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _PriorityBadge(todo.priority),
                  Text('Создано: ${formatDate(todo.createdAt)}'),
                ],
              ),
              if (todo.dueDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    todo.isOverdue
                        ? 'Просрочено: ${formatDateTime(todo.dueDate!)}'
                        : 'Срок: ${formatDateTime(todo.dueDate!)}',
                    style: TextStyle(
                      color: todo.isOverdue ? Colors.red : null,
                      fontWeight: todo.isOverdue ? FontWeight.bold : null,
                    ),
                  ),
                ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Удалить',
            onPressed: () async {
              if (await _confirmDelete(context)) state.delete(todo.id);
            },
          ),
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge(this.priority);

  final Priority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: priority.color,
        ),
      ),
    );
  }
}