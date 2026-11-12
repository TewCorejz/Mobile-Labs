import 'package:material_ui/material_ui.dart';

import '../../data/models/daily_forecast.dart';
import '../utils/formatters.dart';
import 'forecast_list.dart';
import 'temperature_chart.dart';

class ForecastSheet extends StatelessWidget {
  const ForecastSheet({super.key, required this.days});

  final List<DailyForecast> days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Прогноз на ${formatDaysCount(days.length)}',
              style: titleStyle,
            ),
            const SizedBox(height: 16),
            ForecastList(days: days),
            const SizedBox(height: 28),
            Text('График температуры', style: titleStyle),
            const SizedBox(height: 8),
            TemperatureChart(days: days),
          ],
        ),
      ),
    );
  }
}