import '../models/todo.dart';

class TodoRepository {
  final List<Todo> _items = [];
  List<Todo> getAll() => List.unmodifiable(_items);

  void add(Todo todo) => _items.add(todo);
  void update(Todo todo) {
    final index = _items.indexWhere((t) => t.id == todo.id);
    if (index != -1) _items[index] = todo;
  }
  void delete(String id) => _items.removeWhere((t) => t.id == id);
}