import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lab5_weather/app.dart';
import 'package:lab5_weather/data/api/weather_api_client.dart';
import 'package:lab5_weather/data/repository/favorites_repository.dart';
import 'package:lab5_weather/data/repository/settings_repository.dart';
import 'package:lab5_weather/data/repository/weather_repository.dart';
import 'package:lab5_weather/presentation/state/favorites_notifier.dart';
import 'package:lab5_weather/presentation/state/settings_notifier.dart';
import 'package:lab5_weather/presentation/state/weather_notifier.dart';

void main() {
  late int requestCount;
  late WeatherApp app;

  setUp(() async {
    requestCount = 0;
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final httpClient = MockClient((request) async {
      requestCount++;
      return http.Response('{}', 200);
    });

    app = WeatherApp(
      weatherNotifier: WeatherNotifier(
        WeatherRepository(WeatherApiClient(httpClient: httpClient)),
      ),
      favoritesNotifier: FavoritesNotifier(FavoritesRepository(preferences)),
      settingsNotifier: SettingsNotifier(SettingsRepository(preferences)),
    );
  });

  testWidgets('показывает стартовый экран и вкладки', (tester) async {
    await tester.pumpWidget(app);

    expect(find.text('Найдите город'), findsOneWidget);
    expect(find.text('Название города'), findsOneWidget);
    expect(find.text('Погода'), findsOneWidget);
    expect(find.text('Избранное'), findsOneWidget);
    expect(find.text('Настройки'), findsOneWidget);
  });

  testWidgets('пустой запрос не отправляется в сеть', (tester) async {
    await tester.pumpWidget(app);

    await tester.enterText(find.byType(EditableText), '   ');
    await tester.tap(find.byTooltip('Найти'));
    await tester.pump();

    expect(find.text('Введите название города'), findsOneWidget);
    expect(requestCount, 0);
  });
}