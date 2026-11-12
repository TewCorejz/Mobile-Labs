import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pressure_unit.dart';

class SettingsRepository {
  const SettingsRepository(this._preferences);

  static const _themeModeKey = 'theme_mode';
  static const _pressureUnitKey = 'pressure_unit';

  final SharedPreferences _preferences;

  ThemeMode loadThemeMode() =>
      ThemeMode.values.asNameMap()[_preferences.getString(_themeModeKey)] ??
      ThemeMode.system;

  PressureUnit loadPressureUnit() =>
      PressureUnit.values.asNameMap()[_preferences.getString(
        _pressureUnitKey,
      )] ??
      PressureUnit.mmHg;

  Future<void> saveThemeMode(ThemeMode mode) =>
      _preferences.setString(_themeModeKey, mode.name);

  Future<void> savePressureUnit(PressureUnit unit) =>
      _preferences.setString(_pressureUnitKey, unit.name);
}