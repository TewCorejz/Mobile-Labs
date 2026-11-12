import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/city.dart';
import '../../data/models/weather.dart';
import '../../data/repository/weather_repository.dart';
import 'weather_state.dart';

typedef WeatherRequest = Future<Weather?> Function();

class WeatherNotifier extends ChangeNotifier {
  WeatherNotifier(this._repository);

  final WeatherRepository _repository;

  WeatherState _state = const WeatherInitial();
  WeatherState get state => _state;

  String? _queryError;
  String? get queryError => _queryError;

  String _query = '';
  String get query => _query;

  bool get isLoading => _state is WeatherLoading;

  WeatherRequest? _lastRequest;
  int _requestId = 0;

  Future<void> search(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      _queryError = 'Введите название города';
      notifyListeners();
      return;
    }

    _queryError = null;
    _query = trimmedQuery;
    await _load(() => _repository.getWeatherByCityName(trimmedQuery));
  }

  Future<void> showCity(City city) async {
    _queryError = null;
    _query = city.name;
    await _load(() => _repository.getWeatherForCity(city));
  }

  Future<void> retry() async {
    final request = _lastRequest;
    if (request == null) return;
    await _load(request);
  }

  void clearQueryError() {
    if (_queryError == null) return;
    _queryError = null;
    notifyListeners();
  }

  Future<void> _load(WeatherRequest request) async {
    _lastRequest = request;
    final requestId = ++_requestId;
    _setState(const WeatherLoading());

    final result = await _fetch(request, _query);

    if (requestId == _requestId) _setState(result);
  }

  Future<WeatherState> _fetch(WeatherRequest request, String query) async {
    try {
      final weather = await request();
      return weather == null ? WeatherEmpty(query) : WeatherSuccess(weather);
    } on ApiException catch (error) {
      return WeatherError(_messageFor(error));
    } catch (_) {
      return const WeatherError('Что-то пошло не так. Попробуйте снова.');
    }
  }

  void _setState(WeatherState state) {
    _state = state;
    notifyListeners();
  }

  String _messageFor(ApiException error) => switch (error) {
    NetworkException() =>
      'Нет подключения к интернету. Проверьте сеть и попробуйте снова.',
    RequestTimeoutException() => 'Сервер не отвечает. Попробуйте позже.',
    BadRequestException(:final reason) =>
      reason == null ? 'Некорректный запрос.' : 'Некорректный запрос: $reason',
    NotFoundException() => 'Данные не найдены (404).',
    ServerException(:final statusCode) =>
      'Ошибка сервера ($statusCode). Попробуйте позже.',
    UnexpectedStatusException(:final statusCode) =>
      'Неожиданный ответ сервера ($statusCode).',
    ParseException() => 'Не удалось обработать ответ сервера.',
  };
}