import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/currency.dart';

class CurrencyApiException implements Exception {
  const CurrencyApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CurrencyApiClient {
  CurrencyApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _baseUrl = 'open.er-api.com';

  Future<ExchangeRate> fetchRate(String base, String target) async {
    final uri = Uri.https(_baseUrl, '/v6/latest/$base');

    try {
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 12),
      );
      if (response.statusCode != HttpStatus.ok) {
        throw CurrencyApiException(
          'Сервис курсов вернул ошибку (${response.statusCode}). '
          'Попробуйте позже.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const CurrencyApiException(
          'Сервис курсов вернул данные в неизвестном формате.',
        );
      }

      if (decoded['result'] != 'success' || decoded['base_code'] != base) {
        throw const CurrencyApiException(
          'Сервис курсов не смог выполнить запрос.',
        );
      }

      final rates = decoded['rates'];
      final rate = rates is Map<String, dynamic> ? rates[target] : null;
      final updatedAt = decoded['time_last_update_unix'];
      if (rate is! num ||
          updatedAt is! num ||
          !updatedAt.isFinite ||
          updatedAt <= 0 ||
          updatedAt > 253402300799 ||
          updatedAt != updatedAt.roundToDouble()) {
        throw const CurrencyApiException(
          'В ответе сервиса отсутствует необходимый курс.',
        );
      }

      final date = DateTime.fromMillisecondsSinceEpoch(
        updatedAt.toInt() * 1000,
        isUtc: true,
      );
      if (!rate.isFinite || rate <= 0) {
        throw const CurrencyApiException(
          'Сервис курсов вернул некорректные данные.',
        );
      }

      return ExchangeRate(
        base: base,
        target: target,
        rate: rate.toDouble(),
        date: date,
      );
    } on CurrencyApiException {
      rethrow;
    } on http.ClientException {
      throw const CurrencyApiException(
        'Не удалось подключиться к сервису курсов. Проверьте интернет.',
      );
    } on TimeoutException {
      throw const CurrencyApiException(
        'Сервис курсов не ответил вовремя. Попробуйте еще раз.',
      );
    } on SocketException {
      throw const CurrencyApiException(
        'Не удалось подключиться к сервису курсов. Проверьте интернет.',
      );
    } on FormatException {
      throw const CurrencyApiException(
        'Сервис курсов вернул некорректный ответ.',
      );
    }
  }

  void close() => _client.close();
}
