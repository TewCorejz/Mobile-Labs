import 'package:flutter_test/flutter_test.dart';

import 'package:lab1_calculator/main.dart';

void main() {
  testWidgets('theme toggle switches between dark and light themes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byTooltip('Включить светлую тему'), findsOneWidget);
    await tester.tap(find.byTooltip('Включить светлую тему'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Включить тёмную тему'), findsOneWidget);
  });

  testWidgets('calculator starts and can solve a simple expression', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('0'), findsWidgets);

    await tester.tap(find.text('1'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('='));
    await tester.pump();

    expect(find.text('3'), findsWidgets);
  });

  testWidgets('natural logarithm button evaluates the entered value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('1'));
    await tester.tap(find.text('ln'));
    await tester.pump();

    expect(find.text('ln(1)'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
  });
}
