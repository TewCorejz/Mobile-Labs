import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab4_calendar/main.dart';
import 'package:lab4_calendar/data/event_repository.dart';
import 'package:lab4_calendar/state/calendar_state.dart';
import 'package:lab4_calendar/utils/date_utils.dart';

Future<void> startApp(WidgetTester tester) async {
  await tester.pumpWidget(CalendarApp(state: CalendarState(EventRepository())));
}

Future<void> createEvent(WidgetTester tester, String title) async {
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  await tester.enterText(find.widgetWithText(TextFormField, 'Название *'), title);
  await tapSave(tester);
}
Future<void> tapSave(WidgetTester tester) async {
  final save = find.text('Сохранить');
  await tester.ensureVisible(save);
  await tester.pumpAndSettle();
  await tester.tap(save);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Заголовок показывает текущую дату (месяц, год)', (tester) async {
    await startApp(tester);

    final now = DateTime.now();
    expect(find.text('${monthNames[now.month - 1]} ${now.year}'), findsOneWidget);
    expect(find.text('Событий нет. Нажмите «+», чтобы добавить.'), findsOneWidget);
  });

  testWidgets('Переход на следующий и предыдущий месяц', (tester) async {
    await startApp(tester);

    final now = DateTime.now();
    final next = DateTime(now.year, now.month + 1, 1);
    final current = '${monthNames[now.month - 1]} ${now.year}';

    await tester.tap(find.byTooltip('Следующий месяц'));
    await tester.pump();
    expect(find.text('${monthNames[next.month - 1]} ${next.year}'), findsOneWidget);

    await tester.tap(find.byTooltip('Предыдущий месяц'));
    await tester.pump();
    expect(find.text(current), findsOneWidget);
  });

  testWidgets('выбор даты меняет заголовок списка', (tester) async {
    await startApp(tester);

    await tester.tap(find.byTooltip('Следующий месяц'));
    await tester.pump();
    await tester.tap(find.text('15'));
    await tester.pump();

    final next = DateTime(DateTime.now().year, DateTime.now().month + 1, 1);
    expect(
      find.text('События на 15 ${monthNamesGenitive[next.month - 1]}'),
      findsOneWidget,
    );
  });

  testWidgets('Событие без названия не сохраняется', (tester) async {
    await startApp(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tapSave(tester);

    expect(find.text('Введите название'), findsOneWidget);
    expect(find.text('Новое событие'), findsOneWidget);
  });

  testWidgets('Создание, редактирование и удаление события', (tester) async {
    await startApp(tester);

    await createEvent(tester, 'Лекция');
    expect(find.text('Лекция'), findsOneWidget);
    expect(find.text('Событий нет. Нажмите «+», чтобы добавить.'), findsNothing);

    await tester.tap(find.text('Лекция'));
    await tester.pumpAndSettle();
    expect(find.text('Редактирование'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Лекция'), 'Семинар');
    await tapSave(tester);
    expect(find.text('Семинар'), findsOneWidget);
    expect(find.text('Лекция'), findsNothing);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();

    expect(find.text('Семинар'), findsNothing);
    expect(find.text('Событий нет. Нажмите «+», чтобы добавить.'), findsOneWidget);
  });

  testWidgets('Несколько событий в один день', (tester) async {
    await startApp(tester);

    await createEvent(tester, 'Лекция');
    await createEvent(tester, 'Качалка');

    expect(find.text('Лекция'), findsOneWidget);
    expect(find.text('Качалка'), findsOneWidget);
  });
}