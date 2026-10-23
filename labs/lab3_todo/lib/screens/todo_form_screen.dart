import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../utils/date_format.dart';

typedef TodoFormResult = ({String title, Priority priority, DateTime? dueDate});

class TodoFormScreen extends StatefulWidget {
  const TodoFormScreen({super.key, this.todo});
  final Todo? todo;

  @override
  State<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late Priority _priority;
  DateTime? _dueDate;
  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _priority = widget.todo?.priority ?? Priority.medium;
    _dueDate = widget.todo?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initial =
        (_dueDate != null && _dueDate!.isAfter(now)) ? _dueDate! : now;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
      helpText: 'Срок выполнения',
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      helpText: 'Время',
    );
    if (time == null || !mounted) return;

    setState(() {
      _dueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final dueChanged = _dueDate != widget.todo?.dueDate;
    if (_dueDate != null && dueChanged && _dueDate!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Срок не может быть в прошлом')),
      );
      return;
    }

    final TodoFormResult result = (
      title: _titleController.text.trim(),
      priority: _priority,
      dueDate: _dueDate,
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.titleSmall;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактирование' : 'Новая задача'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: !_isEditing,
                maxLength: 100,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Название задачи',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название задачи';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              Text('Приоритет', style: labelStyle),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<Priority>(
                  showSelectedIcon: false,
                  segments: [
                    for (final p in Priority.values)
                      ButtonSegment(value: p, label: Text(p.label)),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (s) => setState(() => _priority = s.first),
                ),
              ),
              const SizedBox(height: 16),

              Text('Срок выполнения', style: labelStyle),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDueDate,
                      icon: const Icon(Icons.event),
                      label: Text(
                        _dueDate == null ? 'Не задан' : formatDateTime(_dueDate!),
                      ),
                    ),
                  ),
                  if (_dueDate != null)
                    IconButton(
                      tooltip: 'Убрать срок',
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _dueDate = null),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Сохранить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}