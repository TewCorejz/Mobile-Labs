import 'weather_condition.dart';

class CurrentWeather {
  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    this.pressure,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: DateTime.parse(json['time'] as String),
      temperature: (json['temperature_2m'] as num).toDouble(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      humidity: (json['relative_humidity_2m'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
      condition: WeatherCondition.fromCode(json['weather_code'] as int),
      pressure: (json['pressure_msl'] as num?)?.toDouble(),
    );
  }

  final DateTime time;
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windSpeed;
  final WeatherCondition condition;
  final double? pressure;
}