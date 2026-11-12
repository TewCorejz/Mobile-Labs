import '../../data/models/city.dart';

const _weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

String formatTemperature(double value) {
  final rounded = value.round();
  return rounded > 0 ? '+$rounded°' : '$rounded°';
}

String formatWeekday(DateTime date) => _weekdays[date.weekday - 1];

String formatDaysCount(int count) {
  final lastTwo = count % 100;
  final last = count % 10;
  final word = switch (last) {
    _ when lastTwo >= 11 && lastTwo <= 14 => 'дней',
    1 => 'день',
    2 || 3 || 4 => 'дня',
    _ => 'дней',
  };
  return '$count $word';
}

String? formatLocation(City city) {
  final parts = [city.region, city.country]
      .whereType<String>()
      .where((part) => part.isNotEmpty && part != city.name)
      .toSet();
  return parts.isEmpty ? null : parts.join(', ');
}