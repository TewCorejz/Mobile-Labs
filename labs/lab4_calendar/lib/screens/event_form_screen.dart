import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/date_utils.dart';
import '../models/event_category.dart';

class EventFormScreen extends StatefulWidget {
  final String id;
  final DateTime initialDate;
  final Event? event;

  const EventFormScreen({
    super.key,
    required this.id,
    required this.initialDate,
    this.event,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late DateTime _date;
  late TimeOfDay _start;
  TimeOfDay? _end;
  late EventCategory _category;

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;

    _titleController = TextEditingController(text: e?.title ?? '');
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _date = dateOnly(e?.date ?? widget.initialDate);
    _category = e?.category ?? EventCategory.other;

    if (e != null) {
      _start = e.start;
      _end = e.end;
    } else {
      final nextHour = (DateTime.now().hour + 1) % 24;
      _start = TimeOfDay(hour: nextHour, minute: 0);
      _end = nextHour < 23 ? TimeOfDay(hour: nextHour + 1, minute: 0) : null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? get _endError {
    final end = _end;
    if (end != null && toMinutes(end) <= toMinutes(_start)) {
      return 'Окончание должно быть позже начала';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Выберите дату',
      cancelText: 'Отмена',
      confirmText: 'OK',
    );
    if (picked != null) {
      setState(() => _date = dateOnly(picked));
    }
  }

  Future<TimeOfDay?> _showTime(TimeOfDay initial, String title) {
    return showTimePicker(
      context: context,
      initialTime: initial,
      helpText: title,
      cancelText: 'Отмена',
      confirmText: 'OK',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
  }

  Future<void> _pickStart() async {
    final t = await _showTime(_start, 'Время начала');
    if (t != null) setState(() => _start = t);
  }

  Future<void> _pickEnd() async {
    final initial =
        _end ?? TimeOfDay(hour: (_start.hour + 1) % 24, minute: _start.minute);
    final t = await _showTime(initial, 'Время окончания');
    if (t != null) setState(() => _end = t);
  }

  void _save() {
    final titleOk = _formKey.currentState!.validate();
    if (!titleOk || _endError != null) return;

    final description = _descriptionController.text.trim();

    final event = Event(
      id: widget.id,
      title: _titleController.text.trim(),
      description: description.isEmpty ? null : description,
      date: _date,
      start: _start,
      end: _end,
      category: _category,
    );
    Navigator.pop(context, event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактирование' : 'Новое событие'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: !_isEditing,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Название *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Описание (необязательно)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EventCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Категория',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final category in EventCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                ],
                onChanged: (category) {
                  if (category == null) return;
                    setState(() => _category = category);
                  },
              ),
              const SizedBox(height: 24),
              _PickerField(
                label: 'Дата',
                value: formatDate(_date),
                icon: Icons.calendar_today,
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              _PickerField(
                label: 'Начало',
                value: formatTime(_start),
                icon: Icons.schedule,
                onTap: _pickStart,
              ),
              const SizedBox(height: 16),
              _PickerField(
                label: 'Окончание',
                value: _end == null ? 'не указано' : formatTime(_end!),
                icon: Icons.schedule_outlined,
                onTap: _pickEnd,
                errorText: _endError,
                onClear: _end == null ? null : () => setState(() => _end = null),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final String? errorText;
  final VoidCallback? onClear;

  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.errorText,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
          suffixIcon: onClear == null
              ? null
              : Material(
                  type: MaterialType.transparency,
                  child: IconButton(
                    tooltip: 'Очистить',
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      onClear!();
                    },
                  ),
                ),
        ),
        child: Text(value),
      ),
    );
  }
}
