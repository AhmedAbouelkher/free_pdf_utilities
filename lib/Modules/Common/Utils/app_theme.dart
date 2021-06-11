import 'package:flutter/material.dart';

RoundedRectangleBorder get _roundedShape {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10.0),
  );
}

TextButtonThemeData get _textButtonTheme {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      tapTargetSize: MaterialTapTargetSize.padded,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      shape: _roundedShape,
    ),
  );
}

DialogTheme get _dialogTheme {
  return DialogTheme(
    shape: _roundedShape,
    backgroundColor: ThemeData.dark().scaffoldBackgroundColor,
    titleTextStyle: ThemeData.dark().textTheme.headline1,
    contentTextStyle: ThemeData.dark().textTheme.bodyText1,
  );
}

DialogTheme get _lightDialogTheme {
  return DialogTheme(
    shape: _roundedShape,
    backgroundColor: ThemeData.light().scaffoldBackgroundColor,
    titleTextStyle: ThemeData.light().textTheme.headline1,
    contentTextStyle: ThemeData.light().textTheme.bodyText1,
  );
}

ThemeData darkTheme() {
  return ThemeData.dark().copyWith(
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
    textButtonTheme: _textButtonTheme,
    dialogTheme: _dialogTheme,
    appBarTheme: AppBarTheme(
      elevation: 0.0,
      iconTheme: IconThemeData(
        size: 18,
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

//TODO: [theme] Light theme needs more work.

ThemeData lightTheme() {
  return ThemeData(
    cardColor: Colors.black54,
    brightness: Brightness.light,
    dividerColor: Colors.black12,
    scaffoldBackgroundColor: Color(0xfff7f7f7),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        primary: Colors.grey,
        side: BorderSide(
          color: Colors.grey[400]!,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.cyan,
      foregroundColor: Colors.white,
    ),
    textButtonTheme: _textButtonTheme,
    dialogTheme: _lightDialogTheme,
    appBarTheme: AppBarTheme(
      color: Color(0xFFF6F4F6),
      elevation: 0.0,
      iconTheme: IconThemeData(
        size: 18,
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

T? themed<T>(BuildContext context, {T? dark, T? light}) {
  assert(dark != null || light != null);
  var _theme = Theme.of(context);
  final _isDark = _theme.brightness == Brightness.dark;
  return _isDark ? dark : light;
}
