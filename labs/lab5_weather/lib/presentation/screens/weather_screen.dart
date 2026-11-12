import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/models/weather.dart';
import '../state/favorites_notifier.dart';
import '../state/settings_notifier.dart';
import '../state/weather_notifier.dart';
import '../state/weather_state.dart';
import '../theme/sky_colors.dart';
import '../widgets/city_search_field.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/forecast_sheet.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({
    super.key,
    required this.weatherNotifier,
    required this.favoritesNotifier,
    required this.settingsNotifier,
  });

  final WeatherNotifier weatherNotifier;
  final FavoritesNotifier favoritesNotifier;
  final SettingsNotifier settingsNotifier;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: SkyColors.gradientFor(brightness),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  weatherNotifier,
                  favoritesNotifier,
                  settingsNotifier,
                ]),
                builder: (context, _) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: CitySearchField(
                        query: weatherNotifier.query,
                        errorText: weatherNotifier.queryError,
                        isLoading: weatherNotifier.isLoading,
                        onSearch: weatherNotifier.search,
                        onChanged: (_) => weatherNotifier.clearQueryError(),
                      ),
                    ),
                    Expanded(child: _buildContent(weatherNotifier.state)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(WeatherState state) => switch (state) {
    WeatherInitial() => const EmptyView(
      icon: Icons.travel_explore,
      title: 'Найдите город',
      message: 'Введите название города, чтобы узнать погоду',
      color: SkyColors.foreground,
    ),
    WeatherLoading() => const Center(
      child: CircularProgressIndicator(color: SkyColors.foreground),
    ),
    WeatherSuccess(:final weather) => _buildWeather(weather),
    WeatherEmpty(:final query) => EmptyView(
      icon: Icons.location_off_outlined,
      title: 'Город не найден',
      message:
          'По запросу «$query» ничего не найдено. '
          'Проверьте название.',
      color: SkyColors.foreground,
    ),
    WeatherError(:final message) => ErrorView(
      message: message,
      onRetry: weatherNotifier.retry,
    ),
  };

  Widget _buildWeather(Weather weather) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: SliverToBoxAdapter(
            child: CurrentWeatherCard(
              weather: weather,
              pressureUnit: settingsNotifier.pressureUnit,
              isFavorite: favoritesNotifier.contains(weather.city),
              onFavoriteToggle: () => favoritesNotifier.toggle(weather.city),
            ),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: ForecastSheet(days: weather.daily),
        ),
      ],
    );
  }
}