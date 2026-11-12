import 'package:material_ui/material_ui.dart';

import '../../data/models/daily_forecast.dart';
import '../utils/formatters.dart';
import 'weather_icon.dart';

class ForecastTile extends StatelessWidget {
  const ForecastTile({super.key, required this.day, this.isToday = false});

  final DailyForecast day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Semantics(
      label:
          '${isToday ? 'Сегодня' : formatWeekday(day.date)}: '
          '${day.condition.description}, '
          'максимум ${formatTemperature(day.maxTemperature)}, '
          'минимум ${formatTemperature(day.minTemperature)}',
      excludeSemantics: true,
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isToday ? 'Сегодня' : formatWeekday(day.date),
              style: textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 10),
          WeatherIcon(day.condition, size: 30),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatTemperature(day.maxTemperature),
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatTemperature(day.minTemperature),
              style: textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}