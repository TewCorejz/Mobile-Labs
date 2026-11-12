import 'package:material_ui/material_ui.dart';

import '../../data/models/weather_condition.dart';

class WeatherIcon extends StatelessWidget {
  const WeatherIcon(
    this.condition, {
    super.key,
    this.size = 24,
    this.onSky = false,
  });

  final WeatherCondition condition;
  final double size;
  final bool onSky;

  static const _sun = Color(0xFFFFC83D);
  static const _rain = Color(0xFF64B5F6);
  static const _storm = Color(0xFF9575CD);

  Color get _cloud => onSky ? Colors.white : const Color(0xFF9EC3EC);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: condition.description,
      child: SizedBox.square(dimension: size, child: _buildIcon()),
    );
  }

  Widget _buildIcon() => switch (condition) {
    WeatherCondition.clear => _icon(Icons.wb_sunny, _sun),
    WeatherCondition.mainlyClear ||
    WeatherCondition.partlyCloudy => _sunBehindCloud(),
    WeatherCondition.overcast => _icon(Icons.cloud, _cloud),
    WeatherCondition.fog => _icon(Icons.foggy, _cloud),
    WeatherCondition.drizzle => _icon(Icons.grain, _rain),
    WeatherCondition.rain ||
    WeatherCondition.rainShowers => _icon(Icons.water_drop, _rain),
    WeatherCondition.snow => _icon(Icons.ac_unit, _cloud),
    WeatherCondition.snowShowers => _icon(Icons.cloudy_snowing, _cloud),
    WeatherCondition.thunderstorm => _icon(Icons.thunderstorm, _storm),
    WeatherCondition.unknown => _icon(Icons.help_outline, _cloud),
  };

  Widget _icon(IconData icon, Color color) =>
      Icon(icon, size: size, color: color);

  Widget _sunBehindCloud() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Icon(Icons.wb_sunny, size: size * 0.62, color: _sun),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: Icon(Icons.cloud, size: size * 0.82, color: _cloud),
        ),
      ],
    );
  }
}