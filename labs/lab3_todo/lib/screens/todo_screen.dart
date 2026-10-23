import 'package:flutter/material.dart';
import '../state/todo_state.dart';
import '../widgets/todo_tile.dart';
import 'todo_form_screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key, required this.state});
  final TodoState state;

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _searchController = TextEditingController();
  TodoState get state => widget.state;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addTodo() async {
    final result = await Navigator.push<TodoFormResult>(
      context,
      MaterialPageRoute(builder: (_) => const TodoFormScreen()),
    );
    if (result != null) {
      state.add(result.title, priority: result.priority, dueDate: result.dueDate);
    }
  }

  Widget _filterChip(String label, TodoFilter filter, int count) {
    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: state.filter == filter,
      onSelected: (_) => state.setFilter(filter),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои задачи')),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final todos = state.visibleTodos;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: state.setQuery,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    hintText: 'Поиск по названию',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              state.setQuery('');
                            },
                          ),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _filterChip('Все', TodoFilter.all, state.totalCount),
                      _filterChip('Активные', TodoFilter.active, state.activeCount),
                      _filterChip('Выполненные', TodoFilter.done, state.doneCount),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: todos.isEmpty
                    ? Center(
                        child: Text(
                          state.totalCount == 0
                              ? 'Задач пока нет.\nНажмите «+», чтобы добавить.'
                              : 'Ничего не найдено',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                        itemCount: todos.length,
                        itemBuilder: (context, i) =>
                            TodoTile(todo: todos[i], state: state),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        tooltip: 'Добавить задачу',
        child: const Icon(Icons.add),
      ),
    );
  }
}