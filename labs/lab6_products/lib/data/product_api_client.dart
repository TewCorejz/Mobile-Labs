import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/catalog.dart';

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class ProductApiClient {
  static const String catalogUrl =
      'https://raw.githubusercontent.com/TewCorejz/lab6_products/main/api/products.json';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  ProductApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Catalog> fetchCatalog() async {
    final data = await _get(catalogUrl);
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Некорректный ответ сервера');
    }
    return Catalog.fromJson(data);
  }

  Future<dynamic> _get(String url) async {
    try {
      final response = await _client.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 404) {
        throw const ApiException('Каталог не найден на сервере');
      }
      if (response.statusCode != 200) {
        throw ApiException('Ошибка сервера: ${response.statusCode}');
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on SocketException {
      throw const ApiException('Нет подключения к интернету');
    } on TimeoutException {
      throw const ApiException('Сервер не отвечает. Попробуйте позже');
    } on http.ClientException {
      throw const ApiException('Не удалось выполнить запрос');
    } on FormatException {
      throw const ApiException('Некорректный ответ сервера');
    }
  }
}