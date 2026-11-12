import 'package:material_ui/material_ui.dart';

import 'presentation/screens/home_screen.dart';
import 'presentation/state/favorites_notifier.dart';
import 'presentation/state/settings_notifier.dart';
import 'presentation/state/weather_notifier.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp({
    super.key,
    required this.weatherNotifier,
    required this.favoritesNotifier,
    required this.settingsNotifier,
  });

  final WeatherNotifier weatherNotifier;
  final FavoritesNotifier favoritesNotifier;
  final SettingsNotifier settingsNotifier;

  static const _seedColor = Color(0xFF5F8FE8);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsNotifier,
      builder: (context, _) => MaterialApp(
        title: 'Прогноз погоды',
        debugShowCheckedModeBanner: false,
        themeMode: settingsNotifier.themeMode,
        theme: ThemeData(colorSchemeSeed: _seedColor),
        darkTheme: ThemeData(
          colorSchemeSeed: _seedColor,
          brightness: Brightness.dark,
        ),
        home: HomeScreen(
          weatherNotifier: weatherNotifier,
          favoritesNotifier: favoritesNotifier,
          settingsNotifier: settingsNotifier,
        ),
      ),
    );
  }
}