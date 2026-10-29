import '../models/event.dart';
import '../utils/date_utils.dart';
import '../models/event_category.dart';

class EventRepository {
  final Map<String, Event> _events = {};
  int _counter = 0;

  String generateId() {
    _counter++;
    return '${DateTime.now().microsecondsSinceEpoch}_$_counter';
  }

  List<Event> getByDate(DateTime date) {
    final result = _events.values
        .where((e) => isSameDay(e.date, date))
        .toList();
    result.sort((a, b) => toMinutes(a.start).compareTo(toMinutes(b.start)));
    return result;
  }

  List<EventCategory> categoriesForDate(DateTime date) {
    final result = <EventCategory>[];
    for (final e in getByDate(date)) {        // getByDate уже отсортирован
      if (!result.contains(e.category)) {
        result.add(e.category);
      }
      if (result.length == 3) break;
    }
    return result;
  }

  bool hasEvents(DateTime date) =>
      _events.values.any((e) => isSameDay(e.date, date));

  void add(Event event) {
    _events[event.id] = event;
  }
  void update(Event event) {
    if (_events.containsKey(event.id)) {
      _events[event.id] = event;
    }
  }
  void delete(String id) {
    _events.remove(id);
  }
}