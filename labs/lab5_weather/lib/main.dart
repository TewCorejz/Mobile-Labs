import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/api/weather_api_client.dart';
import 'data/repository/favorites_repository.dart';
import 'data/repository/settings_repository.dart';
import 'data/repository/weather_repository.dart';
import 'presentation/state/favorites_notifier.dart';
import 'presentation/state/settings_notifier.dart';
import 'presentation/state/weather_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();

  final weatherNotifier = WeatherNotifier(
    WeatherRepository(WeatherApiClient()),
  );
  final favoritesNotifier = FavoritesNotifier(FavoritesRepository(preferences));
  final settingsNotifier = SettingsNotifier(SettingsRepository(preferences));

  final favorites = favoritesNotifier.cities;
  if (favorites.isNotEmpty) {
    unawaited(weatherNotifier.showCity(favorites.first));
  }

  runApp(
    WeatherApp(
      weatherNotifier: weatherNotifier,
      favoritesNotifier: favoritesNotifier,
      settingsNotifier: settingsNotifier,
    ),
  );
}