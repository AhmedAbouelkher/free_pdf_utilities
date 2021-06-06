import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/shared_prefs_utils.dart';
import 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';
import 'package:free_pdf_utilities/Modules/Settings/settings_service.dart';
import 'package:free_pdf_utilities/Screens/error_db_screen.dart';
import 'package:free_pdf_utilities/Screens/root_screen.dart';
import 'Modules/PDFServices/CompressPDF/pdf_compression_controller.dart';
import 'Modules/Settings/settings_provider.dart';

void main() async {
  if (Platform.isIOS || Platform.isAndroid) {
    log("Sorry, $kAppName isn't designed to run on Mobile Devices...");
    exit(0);
  }
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceUtils.init();

  await Hive.initFlutter(kAppName);

  Hive.registerAdapter(PageOrientationEnumAdapter());
  Hive.registerAdapter(PdfPageFormatEnumAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(PDFExportOptionsAdapter());
  Hive.registerAdapter(PDFCompressionExportOptionsAdapter());
  Hive.registerAdapter(ImageTypeAdapter());
  Hive.registerAdapter(ExportMethodAdapter());

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

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  RoundedRectangleBorder get _roundedShape {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    );
  }

  get _textButtonThemeData {
    TextButtonThemeData(
      style: TextButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.padded,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        shape: _roundedShape,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var _settingBox = SettingService.box;
    if (_settingBox == null) return ErrorDBScreen();
    // return ErrorDBScreen();
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
              darkTheme: ThemeData.dark().copyWith(
                toggleableActiveColor: Colors.blue,
                scaffoldBackgroundColor: const Color(0xFF1D1E1F),
                outlinedButtonTheme: OutlinedButtonThemeData(
                  style: OutlinedButton.styleFrom(
                    primary: Colors.grey,
                    backgroundColor: Colors.grey[850],
                    side: BorderSide(
                      color: Colors.grey[800]!,
                    ),
                  ),
                ),
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                ),
                textButtonTheme: _textButtonThemeData,
                dialogTheme: DialogTheme(
                  shape: _roundedShape,
                  backgroundColor: ThemeData.dark().scaffoldBackgroundColor,
                  titleTextStyle: ThemeData.dark().textTheme.headline1,
                  contentTextStyle: ThemeData.dark().textTheme.bodyText1,
                ),
                appBarTheme: AppBarTheme(
                  elevation: 0.0,
                  iconTheme: IconThemeData(
                    size: 18,
                  ),
                ),
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
            ),
          );
        },
      ),
    );
  }
}
