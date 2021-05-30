import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';
import 'package:free_pdf_utilities/Modules/Widgets/dropDown_listTile.dart';
import 'package:free_pdf_utilities/Screens/root_screen.dart';

import '../settings_provider.dart';

enum SettingsTap {
  General,
  ExportOptions,
  About,
}

class SettingsScreen extends StatefulWidget {
  final SettingsTap settingsTap;
  const SettingsScreen({
    Key? key,
    this.settingsTap = SettingsTap.General,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late PageController _pageController;

  List<String> _taps = ['General', 'Export Options', 'About'];
  List<IconData> _tapsIcons = [
    CupertinoIcons.slider_horizontal_3,
    CupertinoIcons.square_arrow_up,
    CupertinoIcons.folder_badge_person_crop,
  ];

  late int _currentTap;

  @override
  void initState() {
    _currentTap = SettingsTap.values.indexOf(widget.settingsTap);
    _pageController = PageController(initialPage: _currentTap);

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleSave(AppSettings newSettings) {
    context.read<AppSettingsProvider>().saveSettings(newSettings);
  }

  void _handleExportOptionsReset() {
    context.read<AppSettingsProvider>().resetExportOptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAppBar(
        hideAppName: true,
        leading: [],
        actions: [IconButton(splashRadius: 15, icon: Icon(Icons.close), onPressed: () => Navigator.pop(context))],
        title: "Settings",
      ),
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                color: Color(0x0AFFFFFF),
                child: ListView.builder(
                  itemCount: _taps.length,
                  padding: const EdgeInsetsDirectional.only(start: 20.0, top: 10.0),
                  itemBuilder: (context, index) {
                    final String _tap = _taps[index];
                    return ListTile(
                      leading: Icon(_tapsIcons[index], size: 18),
                      title: Text(
                        _tap,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                      selectedTileColor: Theme.of(context).hoverColor,
                      selected: _currentTap == index,
                      onTap: () {
                        setState(() => _currentTap = index);
                        // _pageController.animateToPage(index, duration: kDuration, curve: Curves.decelerate);
                        _pageController.jumpToPage(index);
                      },
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 50,
              child: const VerticalDivider(
                width: 0,
                thickness: 2,
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: kMainPadding,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  children: [
                    GeneralSettingsTap(onSave: _handleSave),
                    ExportOptionsSettingsTap(
                      onSave: _handleSave,
                      reset: _handleExportOptionsReset,
                    ),
                    Container(color: Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExportOptionsSettingsTap extends StatelessWidget {
  final ValueChanged<AppSettings> onSave;
  final VoidCallback reset;
  const ExportOptionsSettingsTap({
    Key? key,
    required this.onSave,
    required this.reset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _appSettings = context.watch<AppSettingsProvider>().appSettings();

    void _callOnSave(PDFExportOptions exportOptions) {
      // final _appSettingsUpdated = context.read<AppSettingsProvider>().appSettings();
      // final _options = _appSettingsUpdated.exportOptions!.merge(exportOptions);
      onSave(AppSettings(exportOptions: exportOptions));
    }

    return ListView(
      children: [
        Text('Export Options', style: Theme.of(context).textTheme.headline6),
        const SizedBox(height: 20),
        ListTile(
          subtitle: const Text(
            'Select exported PDF paper size...',
            style: TextStyle(fontSize: 12),
          ),
          title: DropDownListTile<PdfPageFormatEnum>(
            title: "Paper Size",
            initialValue: _appSettings.exportOptions!.pageFormat!,
            options: const [
              DropdownMenuItem(
                child: Text("A3"),
                value: PdfPageFormatEnum.A3,
              ),
              DropdownMenuItem(
                child: Text("A4"),
                value: PdfPageFormatEnum.A4,
              ),
              DropdownMenuItem(
                child: Text("A5"),
                value: PdfPageFormatEnum.A5,
              ),
              DropdownMenuItem(
                child: Text("Letter"),
                value: PdfPageFormatEnum.Letter,
              ),
            ],
            onChanged: (pageFormate) {
              _callOnSave(PDFExportOptions(pageFormat: pageFormate));
            },
          ),
        ),
        const Divider(),
        ListTile(
          subtitle: const Text(
            'Select exported PDF layout Orientation...',
            style: TextStyle(fontSize: 12),
          ),
          title: DropDownListTile<PageOrientationEnum>(
            title: "Layout",
            initialValue: _appSettings.exportOptions!.pageOrientation!,
            options: const [
              DropdownMenuItem(
                child: Text("Portrait"),
                value: PageOrientationEnum.Portrait,
              ),
              DropdownMenuItem(
                child: Text("Landscape"),
                value: PageOrientationEnum.Landscape,
              ),
            ],
            onChanged: (pageOrientation) {
              _callOnSave(PDFExportOptions(pageOrientation: pageOrientation));
            },
          ),
        ),
        const Divider(),
        ListTile(
          title: const Text(
            'Reset to default export options',
            style: TextStyle(fontSize: 12),
          ),
          trailing: OutlinedButton(
            onPressed: reset,
            child: const Text(
              'Reset',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

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
            // enabled: false,
            title: "App Theme",
            initialValue: _appSettings.themeMode!,
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
        // const Divider(),
      ],
    );
  }
}
