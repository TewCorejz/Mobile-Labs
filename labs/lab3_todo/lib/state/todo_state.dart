import 'package:flutter/foundation.dart';
import '../data/todo_repository.dart';
import '../models/todo.dart';

enum TodoFilter { all, active, done }

class TodoState extends ChangeNotifier {
  TodoState(this._repo);
  final TodoRepository _repo;
  TodoFilter _filter = TodoFilter.all;
  String _query = '';
  TodoFilter get filter => _filter;
  int get totalCount => _repo.getAll().length;
  int get activeCount => _repo.getAll().where((t) => !t.isDone).length;
  int get doneCount => totalCount - activeCount;

  List<Todo> get visibleTodos {
    final q = _query.trim().toLowerCase();
    return _repo.getAll().where((t) {
      final matchesFilter = switch (_filter) {
        TodoFilter.all => true,
        TodoFilter.active => !t.isDone,
        TodoFilter.done => t.isDone,
      };
      return matchesFilter && t.title.toLowerCase().contains(q);
    }).toList();
  }

  void add(String title, {Priority priority = Priority.medium, DateTime? dueDate}) {
    _repo.add(Todo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      createdAt: DateTime.now(),
      priority: priority,
      dueDate: dueDate,
    ));
    notifyListeners();
  }
  void update(Todo todo) {
    _repo.update(todo);
    notifyListeners();
  }
  void toggleDone(Todo todo) {
    _repo.update(todo.copyWith(isDone: !todo.isDone));
    notifyListeners();
  }
  void delete(String id) {
    _repo.delete(id);
    notifyListeners();
  }
  void setFilter(TodoFilter f) {
    _filter = f;
    notifyListeners();
  }
  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }
}