class Currency {
  const Currency({required this.code, required this.name});

  final String code;
  final String name;
}

const supportedCurrencies = <Currency>[
  Currency(code: 'AUD', name: 'Австралийский доллар'),
  Currency(code: 'BRL', name: 'Бразильский реал'),
  Currency(code: 'CAD', name: 'Канадский доллар'),
  Currency(code: 'CHF', name: 'Швейцарский франк'),
  Currency(code: 'CNY', name: 'Китайский юань'),
  Currency(code: 'CZK', name: 'Чешская крона'),
  Currency(code: 'DKK', name: 'Датская крона'),
  Currency(code: 'EUR', name: 'Евро'),
  Currency(code: 'GBP', name: 'Фунт стерлингов'),
  Currency(code: 'HKD', name: 'Гонконгский доллар'),
  Currency(code: 'HUF', name: 'Венгерский форинт'),
  Currency(code: 'IDR', name: 'Индонезийская рупия'),
  Currency(code: 'ILS', name: 'Израильский шекель'),
  Currency(code: 'INR', name: 'Индийская рупия'),
  Currency(code: 'ISK', name: 'Исландская крона'),
  Currency(code: 'JPY', name: 'Японская иена'),
  Currency(code: 'KRW', name: 'Южнокорейская вона'),
  Currency(code: 'MXN', name: 'Мексиканское песо'),
  Currency(code: 'MYR', name: 'Малайзийский ринггит'),
  Currency(code: 'NOK', name: 'Норвежская крона'),
  Currency(code: 'NZD', name: 'Новозеландский доллар'),
  Currency(code: 'PHP', name: 'Филиппинское песо'),
  Currency(code: 'PLN', name: 'Польский злотый'),
  Currency(code: 'RON', name: 'Румынский лей'),
  Currency(code: 'RUB', name: 'Российский рубль'),
  Currency(code: 'SEK', name: 'Шведская крона'),
  Currency(code: 'SGD', name: 'Сингапурский доллар'),
  Currency(code: 'THB', name: 'Тайский бат'),
  Currency(code: 'TRY', name: 'Турецкая лира'),
  Currency(code: 'USD', name: 'Доллар США'),
  Currency(code: 'VND', name: 'Вьетнамский донг'),
  Currency(code: 'ZAR', name: 'Южноафриканский рэнд'),
];

class ExchangeRate {
  const ExchangeRate({
    required this.base,
    required this.target,
    required this.rate,
    required this.date,
  });

  final String base;
  final String target;
  final double rate;
  final DateTime date;
}

class ConversionHistoryEntry {
  const ConversionHistoryEntry({
    required this.amount,
    required this.result,
    required this.rate,
    required this.sourceCode,
    required this.targetCode,
    required this.rateDate,
    required this.convertedAt,
  });

  final double amount;
  final double result;
  final double rate;
  final String sourceCode;
  final String targetCode;
  final DateTime rateDate;
  final DateTime convertedAt;

  Map<String, Object> toJson() => {
    'amount': amount,
    'result': result,
    'rate': rate,
    'sourceCode': sourceCode,
    'targetCode': targetCode,
    'rateDate': rateDate.toIso8601String(),
    'convertedAt': convertedAt.toIso8601String(),
  };

  factory ConversionHistoryEntry.fromJson(Map<String, dynamic> json) {
    final amount = json['amount'];
    final result = json['result'];
    final rate = json['rate'];
    final sourceCode = json['sourceCode'];
    final targetCode = json['targetCode'];
    final rateDate = json['rateDate'];
    final convertedAt = json['convertedAt'];
    if (amount is! num ||
        result is! num ||
        rate is! num ||
        sourceCode is! String ||
        targetCode is! String ||
        rateDate is! String ||
        convertedAt is! String) {
      throw const FormatException('Invalid conversion history entry');
    }

    final parsedRateDate = DateTime.tryParse(rateDate);
    final parsedConvertedAt = DateTime.tryParse(convertedAt);
    if (parsedRateDate == null || parsedConvertedAt == null) {
      throw const FormatException('Invalid conversion history date');
    }

    return ConversionHistoryEntry(
      amount: amount.toDouble(),
      result: result.toDouble(),
      rate: rate.toDouble(),
      sourceCode: sourceCode,
      targetCode: targetCode,
      rateDate: parsedRateDate,
      convertedAt: parsedConvertedAt,
    );
  }
}
