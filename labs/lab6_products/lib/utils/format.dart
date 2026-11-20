String formatPrice(num value) {
  final digits = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write('\u00A0');
  }
  return '${buffer.toString()}\u00A0₽';
}

String formatRating(double rating) => rating.toStringAsFixed(1);