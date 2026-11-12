import '../../data/models/weather.dart';

sealed class WeatherState {
  const WeatherState();
}

final class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

final class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

final class WeatherSuccess extends WeatherState {
  const WeatherSuccess(this.weather);

  final Weather weather;
}

final class WeatherEmpty extends WeatherState {
  const WeatherEmpty(this.query);

  final String query;
}

final class WeatherError extends WeatherState {
  const WeatherError(this.message);

  final String message;
}