import 'package:material_ui/material_ui.dart';

import '../../data/models/pressure_unit.dart';
import '../../data/repository/settings_repository.dart';

class SettingsNotifier extends ChangeNotifier {
  SettingsNotifier(this._repository)
    : _themeMode = _repository.loadThemeMode(),
      _pressureUnit = _repository.loadPressureUnit();

  final SettingsRepository _repository;

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  PressureUnit _pressureUnit;
  PressureUnit get pressureUnit => _pressureUnit;

  Future<void> setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    return _repository.saveThemeMode(mode);
  }

  Future<void> setPressureUnit(PressureUnit unit) {
    _pressureUnit = unit;
    notifyListeners();
    return _repository.savePressureUnit(unit);
  }
}