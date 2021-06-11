import 'package:flutter/material.dart';
import 'package:free_pdf_utilities/Modules/Widgets/dropDown_listTile.dart';

import '../../settings_provider.dart';

class GeneralSettingsTap extends StatelessWidget {
  final ValueChanged<AppSettings> onSave;
  const GeneralSettingsTap({
    Key? key,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _appSettings = context.watch<AppSettingsProvider>().appSettings();

    return ListView(
      children: [
        Text('General', style: Theme.of(context).textTheme.headline6),
        const SizedBox(height: 20),
        ListTile(
          subtitle: const Text(
            'Select a theme or switch according to system settings..',
            style: TextStyle(fontSize: 12),
          ),
          title: DropDownListTile<String>(
            title: "App Theme",
            initialValue: _appSettings.themeMode ?? SettingsThemeMode.dark,
            options: const [
              DropdownMenuItem(
                child: Text("Dark"),
                value: SettingsThemeMode.dark,
              ),
              DropdownMenuItem(
                child: Text("Light"),
                value: SettingsThemeMode.light,
              ),
              DropdownMenuItem(
                child: Text("System"),
                value: SettingsThemeMode.system,
              ),
            ],
            onChanged: (value) {
              final _appSettings = AppSettings(themeMode: value);
              onSave(_appSettings);
            },
          ),
        ),
        const Divider(),
        ListTile(
          title: const Text(
            'Clear all Settings from local DB...',
            style: TextStyle(fontSize: 12),
          ),
          trailing: OutlinedButton(
            onPressed: () async {
              var read = context.read<AppSettingsProvider>();
              await read.clearAllSettings();
            },
            child: const Text(
              'Clear',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
