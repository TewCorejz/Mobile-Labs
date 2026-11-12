import '../api/weather_api_client.dart';
import '../models/city.dart';
import '../models/weather.dart';

class WeatherRepository {
  const WeatherRepository(this._apiClient);

  final WeatherApiClient _apiClient;

  Future<Weather?> getWeatherByCityName(String cityName) async {
    final cities = await _apiClient.searchCities(cityName);
    if (cities.isEmpty) return null;

    return _apiClient.fetchWeather(cities.first);
  }

  Future<Weather> getWeatherForCity(City city) => _apiClient.fetchWeather(city);
}