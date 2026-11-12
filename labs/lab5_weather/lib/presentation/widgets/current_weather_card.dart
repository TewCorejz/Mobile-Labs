import 'package:material_ui/material_ui.dart';

import '../../data/models/pressure_unit.dart';
import '../../data/models/weather.dart';
import '../theme/sky_colors.dart';
import '../utils/formatters.dart';
import 'weather_icon.dart';
import 'weather_metrics_panel.dart';

class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({
    super.key,
    required this.weather,
    required this.pressureUnit,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  final Weather weather;
  final PressureUnit pressureUnit;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final current = weather.current;
    final location = formatLocation(weather.city);

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 48),
            Expanded(
              child: Column(
                children: [
                  Text(
                    weather.city.name,
                    style: textTheme.titleLarge?.copyWith(
                      color: SkyColors.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (location != null)
                    Text(
                      location,
                      style: textTheme.bodyMedium?.copyWith(
                        color: SkyColors.secondaryForeground,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: isFavorite
                  ? 'Убрать из избранного'
                  : 'Добавить в избранное',
              onPressed: onFavoriteToggle,
              icon: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFavorite
                    ? const Color(0xFFFFC83D)
                    : SkyColors.foreground,
                size: 30,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WeatherIcon(current.condition, size: 96, onSky: true),
            const SizedBox(width: 16),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatTemperature(current.temperature),
                  style: textTheme.displayLarge?.copyWith(
                    color: SkyColors.foreground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          current.condition.description,
          style: textTheme.headlineSmall?.copyWith(
            color: SkyColors.foreground,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'Ощущается как ${formatTemperature(current.apparentTemperature)}',
          style: textTheme.bodyMedium?.copyWith(
            color: SkyColors.secondaryForeground,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        WeatherMetricsPanel(current: current, pressureUnit: pressureUnit),
      ],
    );
  }
}