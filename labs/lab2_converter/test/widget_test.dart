import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab2_converter/data/currency_repository.dart';
import 'package:lab2_converter/main.dart';
import 'package:lab2_converter/models/currency.dart';
import 'package:lab2_converter/state/converter_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('converts an amount and displays the rate', (tester) async {
    final repository = _FakeCurrencyRepository();
    final state = ConverterState(repository: repository);
    await tester.pumpWidget(CurrencyConverterApp(state: state));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('amount-input')), '100');
    await tester.tap(find.byKey(const Key('convert-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('result-card')), findsOneWidget);
    expect(find.text('9573,1 RUB'), findsOneWidget);
    expect(find.text('100 EUR = 9573,1 RUB'), findsOneWidget);
    expect(find.text('1 EUR = 95,731 RUB'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    final savedHistory = jsonDecode(
      preferences.getString('conversion_history')!,
    ) as List<dynamic>;
    expect(savedHistory, hasLength(1));
    expect(
      (savedHistory.single as Map<String, dynamic>)['result'],
      closeTo(9573.1, 0.000001),
    );

    await tester.tap(find.byKey(const Key('history-button')));
    await tester.pumpAndSettle();
    expect(find.text('История конвертаций'), findsOneWidget);
    expect(find.text('100 EUR  →  9573,1 RUB'), findsOneWidget);
    expect(find.byKey(const Key('history-entry-0')), findsOneWidget);

    await tester.tap(find.byKey(const Key('clear-history-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Очистить'));
    await tester.pumpAndSettle();
    expect(find.text('Пока нет конвертаций'), findsOneWidget);
    expect(jsonDecode(preferences.getString('conversion_history')!), isEmpty);
  });

  testWidgets('shows errors for empty and negative amounts', (tester) async {
    final repository = _FakeCurrencyRepository();
    final state = ConverterState(repository: repository);
    await tester.pumpWidget(CurrencyConverterApp(state: state));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('convert-button')));
    await tester.pump();
    expect(find.text('Введите сумму для конвертации.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('amount-input')), '-3');
    await tester.tap(find.byKey(const Key('convert-button')));
    await tester.pump();

    expect(find.text('Сумма должна быть больше нуля.'), findsOneWidget);
    expect(repository.requests, isEmpty);
  });

  testWidgets('swapping currencies reverses the conversion direction', (
    tester,
  ) async {
    final repository = _FakeCurrencyRepository();
    final state = ConverterState(repository: repository);
    await tester.pumpWidget(CurrencyConverterApp(state: state));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('amount-input')), '100');
    await tester.tap(find.byKey(const Key('swap-currencies')));
    await tester.pumpAndSettle();

    expect(repository.requests, [('RUB', 'EUR')]);
    expect(find.text('200 EUR'), findsOneWidget);
  });

  testWidgets('can add a currency to favorites from the picker', (
    tester,
  ) async {
    final state = ConverterState(repository: _FakeCurrencyRepository());
    await tester.pumpWidget(CurrencyConverterApp(state: state));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Евро'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'USD');
    await tester.pump();
    await tester.tap(find.byKey(const Key('toggle-favorite-USD')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Доллар США'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('favorite-USD')), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getStringList('favorite_currency_codes'), ['USD']);
  });
}

class _FakeCurrencyRepository implements CurrencyRepository {
  final requests = <(String, String)>[];

  @override
  Future<ExchangeRate> getRate(String base, String target) async {
    requests.add((base, target));
    return ExchangeRate(
      base: base,
      target: target,
      rate: base == 'RUB' ? 2 : 95.731,
      date: DateTime.utc(2026, 10, 9),
    );
  }

  @override
  void dispose() {}
}
