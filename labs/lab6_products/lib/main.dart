import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'data/product_repository.dart';
import 'screens/home_screen.dart';
import 'state/cart_state.dart';
import 'state/product_state.dart';
import 'state/profile_state.dart';

void main() {
  runApp(ProductCatalogApp(repository: ProductRepository()));
}

class ProductCatalogApp extends StatelessWidget {
  const ProductCatalogApp({super.key, required this.repository});

  final ProductRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductState(repository)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartState(repository)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileState(repository)..init(),
        ),
      ],
      child: MaterialApp(
        title: 'Продукты',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        home: const HomeScreen(),
      ),
    );
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3B6FF5),
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
    );
  }
}