abstract final class ApiConfig {
  static const geocodingHost = 'geocoding-api.open-meteo.com';
  static const geocodingPath = '/v1/search';

  static const forecastHost = 'api.open-meteo.com';
  static const forecastPath = '/v1/forecast';

  static const language = 'ru';
  static const forecastDays = 7;
  static const windSpeedUnit = 'ms';
  static const requestTimeout = Duration(seconds: 10);
  static const citySearchLimit = 1;

  static const currentFields = 'temperature_2m,relative_humidity_2m,'
      'apparent_temperature,weather_code,wind_speed_10m,pressure_msl';

  static const dailyFields =
      'weather_code,temperature_2m_max,temperature_2m_min';
}