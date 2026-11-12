import 'package:material_ui/material_ui.dart';

import '../../data/models/pressure_unit.dart';
import '../state/settings_notifier.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.settingsNotifier});

  final SettingsNotifier settingsNotifier;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleSmall;

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListenableBuilder(
        listenable: settingsNotifier,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Тема', style: titleStyle),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('Авто')),
                  ButtonSegment(value: ThemeMode.light, label: Text('Светлая')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Тёмная')),
                ],
                selected: {settingsNotifier.themeMode},
                onSelectionChanged: (selection) =>
                    settingsNotifier.setThemeMode(selection.first),
              ),
            ),
            const SizedBox(height: 24),
            Text('Единицы давления', style: titleStyle),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<PressureUnit>(
                showSelectedIcon: false,
                segments: [
                  for (final unit in PressureUnit.values)
                    ButtonSegment(value: unit, label: Text(unit.label)),
                ],
                selected: {settingsNotifier.pressureUnit},
                onSelectionChanged: (selection) =>
                    settingsNotifier.setPressureUnit(selection.first),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.info_outline),
              title: Text('Источник данных'),
              subtitle: Text('Open-Meteo.com, лицензия CC BY 4.0'),
            ),
          ],
        ),
      ),
    );
  }
}