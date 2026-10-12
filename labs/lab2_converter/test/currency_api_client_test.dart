import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab2_converter/data/currency_api_client.dart';

void main() {
  test('parses a successful response including RUB and update time', () async {
    final client = CurrencyApiClient(
      client: MockClient((request) async {
        expect(request.url.host, 'open.er-api.com');
        expect(request.url.path, '/v6/latest/EUR');
        return http.Response(
          jsonEncode({
            'result': 'success',
            'base_code': 'EUR',
            'time_last_update_unix': 1791504151,
            'rates': {'RUB': 95.731079},
          }),
          200,
        );
      }),
    );

    final rate = await client.fetchRate('EUR', 'RUB');

    expect(rate.base, 'EUR');
    expect(rate.target, 'RUB');
    expect(rate.rate, 95.731079);
    expect(rate.date, DateTime.utc(2026, 10, 9, 0, 2, 31));
    client.close();
  });

  test('reports a server error instead of returning a rate', () async {
    final client = CurrencyApiClient(
      client: MockClient(
        (_) async => http.Response('Service unavailable', 503),
      ),
    );

    await expectLater(
      client.fetchRate('EUR', 'RUB'),
      throwsA(isA<CurrencyApiException>()),
    );
    client.close();
  });

  test('reports a connection error with a useful message', () async {
    final client = CurrencyApiClient(
      client: MockClient((_) async {
        throw http.ClientException('offline');
      }),
    );

    await expectLater(
      client.fetchRate('EUR', 'RUB'),
      throwsA(
        isA<CurrencyApiException>().having(
          (exception) => exception.message,
          'message',
          contains('Проверьте интернет'),
        ),
      ),
    );
    client.close();
  });
}
