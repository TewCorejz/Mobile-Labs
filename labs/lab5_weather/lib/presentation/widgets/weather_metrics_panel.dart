import 'package:material_ui/material_ui.dart';

import '../../data/models/current_weather.dart';
import '../../data/models/pressure_unit.dart';
import '../theme/sky_colors.dart';
import 'weather_metric.dart';

class WeatherMetricsPanel extends StatelessWidget {
  const WeatherMetricsPanel({
    super.key,
    required this.current,
    required this.pressureUnit,
  });

  final CurrentWeather current;
  final PressureUnit pressureUnit;

  @override
  Widget build(BuildContext context) {
    final pressure = current.pressure;
    final metrics = [
      WeatherMetric(
        icon: Icons.water_drop_outlined,
        label: 'Влажность',
        value: '${current.humidity}%',
      ),
      WeatherMetric(
        icon: Icons.air,
        label: 'Ветер',
        value: '${current.windSpeed.round()} м/с',
      ),
      if (pressure != null)
        WeatherMetric(
          icon: Icons.speed,
          label: 'Давление',
          value: '${pressureUnit.fromHpa(pressure)} ${pressureUnit.shortLabel}',
        ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: SkyColors.glass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SkyColors.glassBorder),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (final (index, metric) in metrics.indexed) ...[
              if (index > 0)
                const VerticalDivider(
                  width: 1,
                  indent: 14,
                  endIndent: 14,
                  color: SkyColors.glassBorder,
                ),
              Expanded(child: metric),
            ],
          ],
        ),
      ),
    );
  }
}