import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../core/network/api_exception.dart';
import '../models/city.dart';
import '../models/weather.dart';

class WeatherApiClient {
  WeatherApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<List<City>> searchCities(String name) async {
    final uri = Uri.https(ApiConfig.geocodingHost, ApiConfig.geocodingPath, {
      'name': name,
      'count': '${ApiConfig.citySearchLimit}',
      'language': ApiConfig.language,
      'format': 'json',
    });

    final json = await _get(uri);

    return _parse(() {
      final results = json['results'] as List<dynamic>? ?? const [];
      return results
          .map((item) => City.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Weather> fetchWeather(City city) async {
    final uri = Uri.https(ApiConfig.forecastHost, ApiConfig.forecastPath, {
      'latitude': '${city.latitude}',
      'longitude': '${city.longitude}',
      'current': ApiConfig.currentFields,
      'daily': ApiConfig.dailyFields,
      'timezone': 'auto',
      'forecast_days': '${ApiConfig.forecastDays}',
      'wind_speed_unit': ApiConfig.windSpeedUnit,
    });

    final json = await _get(uri);

    return _parse(() => Weather.fromJson(json, city: city));
  }

  void close() => _httpClient.close();

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final http.Response response;
    try {
      response = await _httpClient.get(uri).timeout(ApiConfig.requestTimeout);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on TimeoutException {
      throw const RequestTimeoutException();
    }

    _checkStatus(response);

    return _parse(
      () => jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  void _checkStatus(http.Response response) {
    final statusCode = response.statusCode;
    switch (statusCode) {
      case >= 200 && < 300:
        return;
      case 400:
        throw BadRequestException(_errorReason(response));
      case 404:
        throw const NotFoundException();
      case >= 500:
        throw ServerException(statusCode);
      default:
        throw UnexpectedStatusException(statusCode);
    }
  }

  String? _errorReason(http.Response response) {
    try {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json case {'reason': final String reason}) return reason;
      return null;
    } on FormatException {
      return null;
    }
  }

  T _parse<T>(T Function() parser) {
    try {
      return parser();
    } on FormatException {
      throw const ParseException();
    } on TypeError {
      throw const ParseException();
    }
  }
}