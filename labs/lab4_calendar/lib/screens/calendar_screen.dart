import 'package:flutter/material.dart';
import '../models/event.dart';
import '../state/calendar_state.dart';
import '../utils/date_utils.dart';
import '../widgets/month_grid.dart';
import 'event_form_screen.dart';

class CalendarScreen extends StatelessWidget {
  final CalendarState state;
  const CalendarScreen({super.key, required this.state});

  Future<void> _openCreate(BuildContext context) async {
    final result = await Navigator.push<Event>(
      context,
      MaterialPageRoute(
        builder: (_) => EventFormScreen(
          id: state.newId(),
          initialDate: state.selectedDate,
        ),
      ),
    );
    if (result != null) {
      state.addEvent(result);
      state.selectDate(result.date);
    }
  }

  Future<void> _openEdit(BuildContext context, Event event) async {
    final result = await Navigator.push<Event>(
      context,
      MaterialPageRoute(
        builder: (_) => EventFormScreen(
          id: event.id,
          initialDate: event.date,
          event: event,
        ),
      ),
    );
    if (result != null) {
      state.updateEvent(result);
      state.selectDate(result.date);
    }
  }

  Future<void> _confirmDelete(BuildContext context, Event event) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить событие?'),
        content: Text('«${event.title}» будет удалено.'),
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
    if (ok == true) {
      state.deleteEvent(event.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Добавить событие',
        onPressed: () => _openCreate(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: state,
          builder: (context, _) {
            final selected = state.selectedDate;
            final events = state.selectedDayEvents;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                _buildHeader(context),
                const SizedBox(height: 8),
                MonthGrid(
                  visibleMonth: state.visibleMonth,
                  selectedDate: selected,
                  dotColors: state.dotColorsFor,
                  onDaySelected: state.selectDate,
                ),
                const Divider(height: 32),
                Text(
                  'События на ${selected.day} ${monthNamesGenitive[selected.month - 1]}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                if (events.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Событий нет. Нажмите «+», чтобы добавить.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                else
                  for (final e in events)
                    _EventTile(
                      event: e,
                      onTap: () => _openEdit(context, e),
                      onDelete: () => _confirmDelete(context, e),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final month = state.visibleMonth;
    return Row(
      children: [
        Expanded(
          child: Text(
            '${monthNames[month.month - 1]} ${month.year}',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          tooltip: 'Предыдущий месяц',
          onPressed: state.previousMonth,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: 'Следующий месяц',
          onPressed: state.nextMonth,
          icon: const Icon(Icons.chevron_right),
        ),
        IconButton(
          tooltip: 'Сегодня',
          onPressed: state.goToToday,
          icon: const Icon(Icons.today),
        ),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _EventTile({
    required this.event,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final time = event.end == null
        ? formatTime(event.start)
        : '${formatTime(event.start)} – ${formatTime(event.end!)}';

    final description = event.description;
    final subtitle = (description == null || description.isEmpty)
        ? '$time · ${event.category.label}'
        : '$time · ${event.category.label} · $description';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: event.category.color,
        ),
      ),
      title: Text(
        event.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        tooltip: 'Удалить',
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}