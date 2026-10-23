import 'package:flutter/material.dart';

enum Priority {
  low('Низкий', Colors.green),
  medium('Средний', Colors.orange),
  high('Высокий', Colors.red);
  const Priority(this.label, this.color);
  final String label;
  final Color color;
}

class Todo {
  final String id;
  final String title;
  final bool isDone;
  final DateTime createdAt;
  final Priority priority;
  final DateTime? dueDate;

  const Todo({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isDone = false,
    this.priority = Priority.medium,
    this.dueDate,
  });

  bool get isOverdue =>
      !isDone && dueDate != null && dueDate!.isBefore(DateTime.now());
      
  Todo copyWith({
    String? title,
    bool? isDone,
    Priority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    );
  }
}