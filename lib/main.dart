import 'dart:io';

import 'package:flutter/material.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/shared_prefs_utils.dart';
import 'package:free_pdf_utilities/Screens/root_screen.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceUtils.init();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle("");
    setWindowMinSize(const Size(800, 500));
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
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      home: const RootScreen(),
      theme: ThemeData.dark().copyWith(
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
      ),
    );
  }
}
