import 'package:material_ui/material_ui.dart';

import '../../data/models/city.dart';
import '../state/favorites_notifier.dart';
import '../state/settings_notifier.dart';
import '../state/weather_notifier.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'weather_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.weatherNotifier,
    required this.favoritesNotifier,
    required this.settingsNotifier,
  });

  final WeatherNotifier weatherNotifier;
  final FavoritesNotifier favoritesNotifier;
  final SettingsNotifier settingsNotifier;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  void _openCity(City city) {
    widget.weatherNotifier.showCity(city);
    setState(() => _selectedTab = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: [
          WeatherScreen(
            weatherNotifier: widget.weatherNotifier,
            favoritesNotifier: widget.favoritesNotifier,
            settingsNotifier: widget.settingsNotifier,
          ),
          FavoritesScreen(
            favoritesNotifier: widget.favoritesNotifier,
            onCitySelected: _openCity,
          ),
          SettingsScreen(settingsNotifier: widget.settingsNotifier),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        backgroundColor: Theme.of(context).colorScheme.surface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud),
            label: 'Погода',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border_rounded),
            selectedIcon: Icon(Icons.star_rounded),
            label: 'Избранное',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}