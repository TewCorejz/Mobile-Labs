import 'package:material_ui/material_ui.dart';

import '../../data/models/daily_forecast.dart';
import 'forecast_tile.dart';

class ForecastList extends StatelessWidget {
  const ForecastList({super.key, required this.days});

  final List<DailyForecast> days;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, day) in days.indexed)
          Expanded(
            child: ForecastTile(day: day, isToday: index == 0),
          ),
      ],
    );
  }
}