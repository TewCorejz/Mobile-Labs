import 'package:material_ui/material_ui.dart';

abstract final class SkyColors {
  static const lightGradient = [
    Color(0xFF5F8FE8),
    Color(0xFF8DB4EE),
    Color(0xFFA9D2DC),
  ];
  static const darkGradient = [
    Color(0xFF1B2D5C),
    Color(0xFF2A4677),
    Color(0xFF345D72),
  ];

  static const foreground = Colors.white;
  static const secondaryForeground = Color(0xDDFFFFFF);
  static const glass = Color(0x33FFFFFF);
  static const glassBorder = Color(0x40FFFFFF);
  static const errorText = Color(0xFFFFE082);

  static List<Color> gradientFor(Brightness brightness) =>
      brightness == Brightness.dark ? darkGradient : lightGradient;
}