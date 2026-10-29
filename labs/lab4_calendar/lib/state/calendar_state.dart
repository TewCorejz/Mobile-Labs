import 'package:flutter/material.dart';
import '../data/event_repository.dart';
import '../models/event.dart';
import '../utils/date_utils.dart';

class CalendarState extends ChangeNotifier {
  final EventRepository repository;
  DateTime _visibleMonth;
  DateTime _selectedDate;

  CalendarState(this.repository)
    : _selectedDate = dateOnly(DateTime.now()),
    _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  DateTime get visibleMonth => _visibleMonth;
  DateTime get selectedDate => _selectedDate;

  List<Event> get selectedDayEvents => repository.getByDate(_selectedDate);

  List<Color> dotColorsFor(DateTime date) =>
    repository.categoriesForDate(date).map((c) => c.color).toList();

  void selectDate(DateTime date) {
    _selectedDate = dateOnly(date);
    _visibleMonth = DateTime(date.year, date.month, 1);
    notifyListeners();
  }

  void nextMonth() => _changeMonth(1);
  void previousMonth() => _changeMonth(-1);

  void _changeMonth(int delta) {
    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);

    final today = dateOnly(DateTime.now());
    if (today.year == _visibleMonth.year && today.month == _visibleMonth.month) {
      _selectedDate = today;
    } else {
      _selectedDate = _visibleMonth;
    }
    notifyListeners();
  }

  void goToToday() {
    final today = dateOnly(DateTime.now());
    _visibleMonth = DateTime(today.year, today.month, 1);
    _selectedDate = today;
    notifyListeners();
  }

  String newId() => repository.generateId();

  void addEvent(Event event) {
    repository.add(event);
    notifyListeners();
  }
  void updateEvent(Event event) {
    repository.update(event);
    notifyListeners();
  }
  void deleteEvent(String id) {
    repository.delete(id);
    notifyListeners();
  }
}