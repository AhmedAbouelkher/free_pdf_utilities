import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

import 'package:free_pdf_utilities/Modules/Common/Utils/command_line_tools.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/shared_prefs_utils.dart';
import 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';
import 'package:free_pdf_utilities/Modules/Settings/settings_service.dart';
import 'package:free_pdf_utilities/Screens/error_db_screen.dart';
import 'package:free_pdf_utilities/Screens/root_screen.dart';
import 'Modules/Common/Utils/app_theme.dart';
import 'Modules/PDFServices/CompressPDF/pdf_compression_controller.dart';
import 'Modules/Settings/settings_provider.dart';

//TODO: Implement light mode
//TODO: fix grammar errors

void main() async {
  if (Platform.isIOS || Platform.isAndroid) {
    log("Sorry, $kAppName isn't designed to run on Mobile Devices...");
    exit(0);
  }
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceUtils.init();

  await Hive.initDB();

  Hive.registerAdapter(PageOrientationEnumAdapter());
  Hive.registerAdapter(PdfPageFormatEnumAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(PDFExportOptionsAdapter());
  Hive.registerAdapter(PDFCompressionExportOptionsAdapter());
  Hive.registerAdapter(ImageTypeAdapter());
  Hive.registerAdapter(ExportMethodAdapter());

  //Clearing temp generated PDF files from the current device.
  clearTempGeneratedCache().then((_) {
    log("`.generated` directory was cleared");
  }).catchError((e) {
    log("Error while clearing `.generated` in `clearTempGeneratedCache()` $e");
  });

  try {
    await SettingService.init();
  } catch (e) {
    print("There was an issue opening the DB | Details: $e");
  }

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle("");
    setWindowMinSize(const Size(600, 500));
    setWindowMaxSize(Size.infinite);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _settingBox = SettingService.box;
    if (_settingBox == null) return ErrorDBScreen();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => PythonCompressionControllerNotifier()),
      ],
      child: ValueListenableBuilder(
        valueListenable: _settingBox.listenable(),
        builder: (context, box, _) {
          final _appSettings = SettingService.read();
          return OKToast(
            child: MaterialApp(
              title: kAppName,
              debugShowCheckedModeBanner: false,
              themeMode: SettingsThemeMode.getThemeMode(_appSettings.themeMode),
              home: const RootScreen(),
              darkTheme: darkTheme(),
              theme: lightTheme(),
            ),
          );
        },
      ),
    );
  }
}
