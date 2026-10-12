import '../models/currency.dart';
import 'currency_api_client.dart';

abstract interface class CurrencyRepository {
  Future<ExchangeRate> getRate(String base, String target);

  void dispose();
}

class ApiCurrencyRepository implements CurrencyRepository {
  ApiCurrencyRepository(this._apiClient);

  final CurrencyApiClient _apiClient;

  @override
  Future<ExchangeRate> getRate(String base, String target) {
    if (base == target) {
      return Future.value(
        ExchangeRate(
          base: base,
          target: target,
          rate: 1,
          date: DateTime.now(),
        ),
      );
    }
    return _apiClient.fetchRate(base, target);
  }

  @override
  void dispose() => _apiClient.close();
}
