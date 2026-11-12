enum WeatherCondition {
  clear('Ясно', [0]),
  mainlyClear('Преимущественно ясно', [1]),
  partlyCloudy('Переменная облачность', [2]),
  overcast('Пасмурно', [3]),
  fog('Туман', [45, 48]),
  drizzle('Морось', [51, 53, 55, 56, 57]),
  rain('Дождь', [61, 63, 65, 66, 67]),
  rainShowers('Ливень', [80, 81, 82]),
  snow('Снег', [71, 73, 75, 77]),
  snowShowers('Снегопад', [85, 86]),
  thunderstorm('Гроза', [95, 96, 99]),
  unknown('Нет данных', []);

  const WeatherCondition(this.description, this.codes);

  final String description;
  final List<int> codes;

  static WeatherCondition fromCode(int code) => values.firstWhere(
        (condition) => condition.codes.contains(code),
        orElse: () => unknown,
      );
}