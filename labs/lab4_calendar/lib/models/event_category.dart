import 'package:flutter/material.dart';

enum EventCategory {
  study('Учёба', Color(0xFF2962FF)),
  work('Работа', Color(0xFFFF6D00)),
  personal('Личное', Color(0xFF00BFA5)),
  sport('Спорт', Color(0xFFAA00FF)),
  other('Другое', Color(0xFF757575));

  final String label;
  final Color color;
  const EventCategory(this.label, this.color);
}