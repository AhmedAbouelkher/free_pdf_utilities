import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';
import 'package:free_pdf_utilities/Modules/Widgets/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;
import '../../settings_provider.dart';
import 'export_options.dart';
import 'general_tap.dart';

//TODO: Add compression settings options
//TODO: refactor this screen
//TODO: document

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
    var _appSettingsProvider = context.read<AppSettingsProvider>();
    _appSettingsProvider.saveSettings(newSettings);
    _appSettingsProvider.clearTempExportOptions();
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
                  physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsetsDirectional.only(start: 20.0, top: 10.0),
                  itemBuilder: (context, index) {
                    final String _tap = _taps[index];
                    return ListTile(
                      leading: Icon(_tapsIcons[index], size: 18),
                      title: Text(
                        _tap,
                        style: TextStyle(fontSize: 13),
                      ),
                      selectedTileColor: Theme.of(context).hoverColor,
                      selected: _currentTap == index,
                      onTap: () {
                        _pageController.jumpToPage(index);
                        setState(() => _currentTap = index);
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
                    //TODO: Impelement About settings tap
                    Container(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FontAwesomeIcons.hammer, size: 50),
                            SizedBox(height: 20),
                            Text("UNDER CONSTRUCTION"),
                            SizedBox(height: 50),
                            TextButton.icon(
                              icon: Icon(FontAwesomeIcons.github, color: Colors.white),
                              label: const Text(
                                "Contribute on Github",
                                style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white),
                              ),
                              onPressed: () {
                                urlLauncher.launch(kAppRepo);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
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
