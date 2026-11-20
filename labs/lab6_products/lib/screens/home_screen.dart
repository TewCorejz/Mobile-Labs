import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../state/cart_state.dart';
import '../state/product_state.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'product_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  void _openTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final favoritesCount =
        context.select<ProductState, int>((s) => s.favoritesCount);
    final cartCount = context.select<CartState, int>((s) => s.totalCount);

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const ProductListScreen(),
          FavoritesScreen(onOpenCatalog: () => _openTab(0)),
          CartScreen(onOpenCatalog: () => _openTab(0)),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _openTab,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Каталог',
          ),
          NavigationDestination(
            icon: _badgeIcon(Icons.favorite_border, favoritesCount),
            selectedIcon: _badgeIcon(Icons.favorite, favoritesCount),
            label: 'Избранное',
          ),
          NavigationDestination(
            icon: _badgeIcon(Icons.shopping_cart_outlined, cartCount),
            selectedIcon: _badgeIcon(Icons.shopping_cart, cartCount),
            label: 'Корзина',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }

  Widget _badgeIcon(IconData icon, int count) {
    return Badge.count(
      count: count,
      isLabelVisible: count > 0,
      child: Icon(icon),
    );
  }
}