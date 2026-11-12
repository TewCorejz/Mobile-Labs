import 'package:material_ui/material_ui.dart';

import '../../data/models/city.dart';
import '../state/favorites_notifier.dart';
import '../utils/formatters.dart';
import '../widgets/empty_view.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.favoritesNotifier,
    required this.onCitySelected,
  });

  final FavoritesNotifier favoritesNotifier;
  final ValueChanged<City> onCitySelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: ListenableBuilder(
        listenable: favoritesNotifier,
        builder: (context, _) {
          final cities = favoritesNotifier.cities;
          if (cities.isEmpty) {
            return const EmptyView(
              icon: Icons.star_border_rounded,
              title: 'Нет избранных городов',
              message:
                  'Найдите город и нажмите на звёздочку, '
                  'чтобы добавить его сюда',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: cities.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final city = cities[index];
              final location = formatLocation(city);
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.location_city)),
                title: Text(
                  city.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: location == null
                    ? null
                    : Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                trailing: IconButton(
                  tooltip: 'Удалить из избранного',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => favoritesNotifier.remove(city),
                ),
                onTap: () => onCitySelected(city),
              );
            },
          );
        },
      ),
    );
  }
}