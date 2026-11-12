import 'city.dart';
import 'current_weather.dart';
import 'daily_forecast.dart';

class Weather {
  const Weather({
    required this.city,
    required this.current,
    required this.daily,
  });

  factory Weather.fromJson(Map<String, dynamic> json, {required City city}) {
    return Weather(
      city: city,
      current: CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
      daily: DailyForecast.listFromJson(json['daily'] as Map<String, dynamic>),
    );
  }

  final City city;
  final CurrentWeather current;
  final List<DailyForecast> daily;
}