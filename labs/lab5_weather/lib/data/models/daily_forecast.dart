import 'weather_condition.dart';

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.condition,
  });

  static List<DailyForecast> listFromJson(Map<String, dynamic> json) {
    final dates = json['time'] as List<dynamic>;
    final codes = json['weather_code'] as List<dynamic>;
    final maxTemperatures = json['temperature_2m_max'] as List<dynamic>;
    final minTemperatures = json['temperature_2m_min'] as List<dynamic>;

    return List.generate(
      dates.length,
      (i) => DailyForecast(
        date: DateTime.parse(dates[i] as String),
        maxTemperature: (maxTemperatures[i] as num).toDouble(),
        minTemperature: (minTemperatures[i] as num).toDouble(),
        condition: WeatherCondition.fromCode(codes[i] as int),
      ),
    );
  }

  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final WeatherCondition condition;
}