import 'package:flutter/material.dart';
import 'event_category.dart';

class Event {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final TimeOfDay start;
  final TimeOfDay? end;
  final EventCategory category;

  const Event({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.start,
    this.end,
    required this.category,
  });
}