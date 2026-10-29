import 'package:flutter/material.dart';
import 'data/event_repository.dart';
import 'screens/calendar_screen.dart';
import 'state/calendar_state.dart';

void main() {
  final state = CalendarState(EventRepository());
  runApp(CalendarApp(state: state));
}

class CalendarApp extends StatelessWidget {
  final CalendarState state;
  const CalendarApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Календарь',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: CalendarScreen(state: state),
    );
  }
}