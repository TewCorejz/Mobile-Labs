import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/currency_api_client.dart';
import '../data/currency_repository.dart';
import '../models/currency.dart';

class ConverterState extends ChangeNotifier {
  ConverterState({
    required this._repository,
    Future<SharedPreferences> Function()? preferencesLoader,
  }) : _preferencesLoader =
           preferencesLoader ?? SharedPreferences.getInstance;

  static const _favoritesKey = 'favorite_currency_codes';
  static const _historyKey = 'conversion_history';
  static const _maxHistoryEntries = 20;

  final CurrencyRepository _repository;
  final Future<SharedPreferences> Function() _preferencesLoader;
  final Set<String> _favoriteCodes = {};

  Currency _sourceCurrency = supportedCurrencies.firstWhere(
    (currency) => currency.code == 'EUR',
  );
  Currency _targetCurrency = supportedCurrencies.firstWhere(
    (currency) => currency.code == 'RUB',
    orElse: () => supportedCurrencies.firstWhere(
      (currency) => currency.code == 'USD',
    ),
  );
  double? _result;
  double? _convertedAmount;
  ExchangeRate? _exchangeRate;
  String? _error;
  String? _favoritesError;
  String? _historyError;
  final List<ConversionHistoryEntry> _history = [];
  bool _isLoading = false;
  int _conversionRequestId = 0;

  Currency get sourceCurrency => _sourceCurrency;
  Currency get targetCurrency => _targetCurrency;
  double? get result => _result;
  double? get convertedAmount => _convertedAmount;
  ExchangeRate? get exchangeRate => _exchangeRate;
  String? get error => _error;
  String? get favoritesError => _favoritesError;
  String? get historyError => _historyError;
  bool get isLoading => _isLoading;
  List<ConversionHistoryEntry> get history =>
      List.unmodifiable(_history);
  List<Currency> get favoriteCurrencies => supportedCurrencies
      .where((currency) => _favoriteCodes.contains(currency.code))
      .toList(growable: false);

  Future<void> initialize() async {
    await Future.wait([_loadFavorites(), _loadHistory()]);
  }

  Future<void> _loadFavorites() async {
    try {
      final preferences = await _preferencesLoader();
      final savedCodes = preferences.getStringList(_favoritesKey) ?? [];
      _favoriteCodes
        ..clear()
        ..addAll(
          savedCodes.where(
            (code) => supportedCurrencies.any(
              (currency) => currency.code == code,
            ),
          ),
        );
      notifyListeners();
    } on PlatformException {
      _favoritesError = 'Не удалось загрузить избранные валюты.';
      notifyListeners();
    } on MissingPluginException {
      _favoritesError = 'Хранилище избранного недоступно на этом устройстве.';
      notifyListeners();
    }
  }

  Future<void> _loadHistory() async {
    try {
      final preferences = await _preferencesLoader();
      final savedHistory = preferences.getString(_historyKey);
      if (savedHistory == null) return;
      final decoded = jsonDecode(savedHistory);
      if (decoded is! List) {
        throw const FormatException('Invalid conversion history');
      }
      _history
        ..clear()
        ..addAll(
          decoded.map((entry) {
            if (entry is! Map<String, dynamic>) {
              throw const FormatException('Invalid conversion history entry');
            }
            return ConversionHistoryEntry.fromJson(entry);
          }).take(_maxHistoryEntries),
        );
      notifyListeners();
    } on FormatException {
      _historyError = 'Не удалось прочитать историю конвертаций.';
      notifyListeners();
    } on PlatformException {
      _historyError = 'Не удалось загрузить историю конвертаций.';
      notifyListeners();
    } on MissingPluginException {
      _historyError = 'Хранилище истории недоступно на этом устройстве.';
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    _history.clear();
    _historyError = null;
    notifyListeners();
    await _persistHistory();
  }

  bool isFavorite(Currency currency) =>
      _favoriteCodes.contains(currency.code);

  Future<void> toggleFavorite(Currency currency) async {
    if (isFavorite(currency)) {
      _favoriteCodes.remove(currency.code);
    } else {
      _favoriteCodes.add(currency.code);
    }
    _favoritesError = null;
    notifyListeners();

    try {
      final preferences = await _preferencesLoader();
      final saved = await preferences.setStringList(
        _favoritesKey,
        favoriteCurrencies.map((item) => item.code).toList(),
      );
      if (!saved) {
        _favoritesError = 'Не удалось сохранить избранные валюты.';
        notifyListeners();
      }
    } on PlatformException {
      _favoritesError = 'Не удалось сохранить избранные валюты.';
      notifyListeners();
    } on MissingPluginException {
      _favoritesError = 'Хранилище избранного недоступно на этом устройстве.';
      notifyListeners();
    }
  }

  void setSourceCurrency(Currency currency) {
    _sourceCurrency = currency;
    _clearConversion();
  }

  void setTargetCurrency(Currency currency) {
    _targetCurrency = currency;
    _clearConversion();
  }

  Future<void> swapCurrencies(String amountText) async {
    final previousSource = _sourceCurrency;
    _sourceCurrency = _targetCurrency;
    _targetCurrency = previousSource;
    _clearConversion();
    if (amountText.trim().isNotEmpty) {
      await convert(amountText);
    }
  }

  Future<void> convert(String amountText) async {
    final normalizedAmount = amountText.trim().replaceAll(',', '.');
    if (normalizedAmount.isEmpty) {
      _setInputError('Введите сумму для конвертации.');
      return;
    }
    final amount = double.tryParse(normalizedAmount);
    if (amount == null || !amount.isFinite) {
      _setInputError('Введите корректную сумму числом.');
      return;
    }
    if (amount <= 0) {
      _setInputError('Сумма должна быть больше нуля.');
      return;
    }

    _isLoading = true;
    final requestId = ++_conversionRequestId;
    _error = null;
    _result = null;
    _convertedAmount = null;
    _exchangeRate = null;
    notifyListeners();

    final sourceCode = _sourceCurrency.code;
    final targetCode = _targetCurrency.code;
    try {
      final rate = await _repository.getRate(
        sourceCode,
        targetCode,
      );
      if (requestId != _conversionRequestId) return;
      _exchangeRate = rate;
      _convertedAmount = amount;
      _result = amount * rate.rate;
      _history.insert(
        0,
        ConversionHistoryEntry(
          amount: amount,
          result: _result!,
          rate: rate.rate,
          sourceCode: sourceCode,
          targetCode: targetCode,
          rateDate: rate.date,
          convertedAt: DateTime.now(),
        ),
      );
      if (_history.length > _maxHistoryEntries) {
        _history.removeRange(_maxHistoryEntries, _history.length);
      }
      await _persistHistory();
    } on CurrencyApiException catch (exception) {
      if (requestId == _conversionRequestId) {
        _error = exception.message;
      }
    } finally {
      if (requestId == _conversionRequestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _persistHistory() async {
    try {
      final preferences = await _preferencesLoader();
      final saved = await preferences.setString(
        _historyKey,
        jsonEncode(_history.map((entry) => entry.toJson()).toList()),
      );
      if (!saved) {
        _historyError = 'Не удалось сохранить историю конвертаций.';
        notifyListeners();
      }
    } on PlatformException {
      _historyError = 'Не удалось сохранить историю конвертаций.';
      notifyListeners();
    } on MissingPluginException {
      _historyError = 'Хранилище истории недоступно на этом устройстве.';
      notifyListeners();
    }
  }

  void _clearConversion() {
    _conversionRequestId++;
    _isLoading = false;
    _result = null;
    _convertedAmount = null;
    _exchangeRate = null;
    _error = null;
    notifyListeners();
  }

  void _setInputError(String message) {
    _conversionRequestId++;
    _isLoading = false;
    _result = null;
    _convertedAmount = null;
    _exchangeRate = null;
    _error = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
