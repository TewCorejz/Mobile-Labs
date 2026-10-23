import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab3_todo/data/todo_repository.dart';
import 'package:lab3_todo/main.dart';
import 'package:lab3_todo/models/todo.dart';
import 'package:lab3_todo/state/todo_state.dart';

void main() {
  late TodoState state;

  setUp(() => state = TodoState(TodoRepository()));

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(TodoApp(state: state));
  }

  Future<void> addTodo(WidgetTester tester, String title) async {
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), title);
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
  }

  testWidgets('1. Добавление задачи с корректным названием', (tester) async {
    await pumpApp(tester);
    await addTodo(tester, 'Купить хлеб');

    expect(find.text('Купить хлеб'), findsOneWidget);
    expect(state.totalCount, 1);
  });

  testWidgets('2. Нельзя сохранить пустое название', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '    ');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(find.text('Введите название задачи'), findsOneWidget);
    expect(state.totalCount, 0);
  });

  testWidgets('3. Изменение названия', (tester) async {
    await pumpApp(tester);
    await addTodo(tester, 'Старое название');

    await tester.tap(find.text('Старое название'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Новое название');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(find.text('Новое название'), findsOneWidget);
    expect(find.text('Старое название'), findsNothing);
  });

  testWidgets('4. Отметка задачи выполненной', (tester) async {
    await pumpApp(tester);
    await addTodo(tester, 'Задача');

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(state.doneCount, 1);
    final text = tester.widget<Text>(find.text('Задача'));
    expect(text.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('5. Удаление задачи', (tester) async {
    await pumpApp(tester);
    await addTodo(tester, 'Удалить меня');

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();

    expect(find.text('Удалить меня'), findsNothing);
    expect(state.totalCount, 0);
  });

  testWidgets('6. Фильтрация активных и выполненных', (tester) async {
    await pumpApp(tester);
    await addTodo(tester, 'Активная');
    await addTodo(tester, 'Готовая');

    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Активные'));
    await tester.pumpAndSettle();
    expect(find.text('Активная'), findsOneWidget);
    expect(find.text('Готовая'), findsNothing);

    await tester.tap(find.textContaining('Выполненные'));
    await tester.pumpAndSettle();
    expect(find.text('Активная'), findsNothing);
    expect(find.text('Готовая'), findsOneWidget);
  });

  testWidgets('7. Поиск по части названия (без учёта регистра)', (tester) async {
    await pumpApp(tester);
    await addTodo(tester, 'Купить молоко');
    await addTodo(tester, 'Сделать лабу');

    await tester.enterText(find.byType(TextField), 'МОЛ');
    await tester.pumpAndSettle();

    expect(find.text('Купить молоко'), findsOneWidget);
    expect(find.text('Сделать лабу'), findsNothing);
  });

  testWidgets('Доп. задание: приоритет и просроченный срок', (tester) async {
    state.add(
      'Срочная задача',
      priority: Priority.high,
      dueDate: DateTime.now().subtract(const Duration(hours: 1)),
    );
    await pumpApp(tester);

    expect(find.text('Высокий'), findsOneWidget);
    expect(find.textContaining('Просрочено'), findsOneWidget);
  });
}