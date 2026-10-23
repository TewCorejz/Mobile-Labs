import 'package:flutter/material.dart';
import 'data/todo_repository.dart';
import 'state/todo_state.dart';
import 'screens/todo_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  final state = TodoState(TodoRepository());
  runApp(TodoApp(state: state));
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key, required this.state});
  final TodoState state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Список задач',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      locale: const Locale('ru'),
      supportedLocales: const [Locale('ru')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: TodoScreen(state: state),
    );
  }
}