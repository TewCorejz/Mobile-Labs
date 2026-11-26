import 'package:material_ui/material_ui.dart';

import 'data/news_api_client.dart';
import 'data/news_repository.dart';
import 'screens/news_screen.dart';
import 'state/news_state.dart';
import 'screens/home_screen.dart';

void main() {
  const apiKey = String.fromEnvironment('NEWS_API_KEY');
  const client = NewsApiClient(apiKey);
  const repository = NewsRepository(client);
  final state = NewsState(repository)..load();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Новости',
      home: HomeScreen(news: NewsScreen(state: state)),
    ),
  );
}
