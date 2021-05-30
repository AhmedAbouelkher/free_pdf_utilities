import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:free_pdf_utilities/Modules/PDFServices/Providers/pdf_assets_controller.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 0)
class AppSettings {
  @HiveField(0, defaultValue: SettingsThemeMode.system)
  final String? themeMode;

  @HiveField(1, defaultValue: const PDFExportOptions())
  final PDFExportOptions? exportOptions;

  const AppSettings({
    this.themeMode = SettingsThemeMode.system,
    this.exportOptions = const PDFExportOptions(),
  });

  AppSettings copyWith({
    String? themeMode,
    PDFExportOptions? exportOptions,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      exportOptions: exportOptions ?? this.exportOptions,
    );
  }

  AppSettings merge(AppSettings? other) {
    if (other == null) return this;
    return copyWith(
      exportOptions: other.exportOptions,
      themeMode: other.themeMode,
    );
  }

  @override
  String toString() => 'AppSettings(themeMode: $themeMode, exportOptions: $exportOptions)';
}

@HiveType(typeId: 22)
enum PdfPageFormatEnum {
  @HiveField(0)
  A3,
  @HiveField(1)
  A4,
  @HiveField(2)
  A5,
  @HiveField(3)
  Letter
}

@HiveType(typeId: 33)
enum PageOrientationEnum {
  @HiveField(0)
  Landscape,
  @HiveField(1)
  Portrait
}

@HiveType(typeId: 1)
class PDFExportOptions {
  @HiveField(0, defaultValue: PdfPageFormatEnum.A4)
  final PdfPageFormatEnum? pageFormat;
  @HiveField(1, defaultValue: PageOrientationEnum.Portrait)
  final PageOrientationEnum? pageOrientation;

  const PDFExportOptions({
    this.pageFormat = PdfPageFormatEnum.A4,
    this.pageOrientation = PageOrientationEnum.Portrait,
  });

  PDFExportOptions copyWith({
    PdfPageFormatEnum? pageFormat,
    PageOrientationEnum? pageOrientation,
  }) {
    return PDFExportOptions(
      pageFormat: pageFormat ?? this.pageFormat,
      pageOrientation: pageOrientation ?? this.pageOrientation,
    );
  }

  PDFExportOptions merge(PDFExportOptions? other) {
    if (other == null) return this;
    return copyWith(
      pageFormat: other.pageFormat,
      pageOrientation: other.pageOrientation,
    );
  }

  @override
  String toString() => 'PDFExportOptions(pageFormat: $pageFormat, pageOrientation: $pageOrientation)';
}

PdfPageFormat getPdfPageFormat(PdfPageFormatEnum pageFormatEnum) {
  switch (pageFormatEnum) {
    case PdfPageFormatEnum.A3:
      return PdfPageFormat.a3;

    case PdfPageFormatEnum.A4:
      return PdfPageFormat.a4;
    case PdfPageFormatEnum.A5:
      return PdfPageFormat.a5;
    default:
      return PdfPageFormat.letter;
  }
}

pw.PageOrientation getPageOrientation(PageOrientationEnum pageOrientationEum) {
  switch (pageOrientationEum) {
    case PageOrientationEnum.Landscape:
      return pw.PageOrientation.landscape;
    default:
      return pw.PageOrientation.portrait;
  }
}

extension PageFormat on PdfPageFormat {
  PdfPageFormatEnum toEnum() {
    if (this.height == PdfPageFormat.a3.height) {
      return PdfPageFormatEnum.A3;
    } else if (this.height == PdfPageFormat.a4.height) {
      return PdfPageFormatEnum.A3;
    } else if (this.height == PdfPageFormat.a5.height) {
      return PdfPageFormatEnum.A5;
    } else {
      return PdfPageFormatEnum.Letter;
    }
  }
}

class SettingsThemeMode {
  static const light = 'light';
  static const dark = 'dark';
  static const system = 'system';

  const SettingsThemeMode();

  static ThemeMode getThemeMode(String themeMode) {
    if (themeMode == SettingsThemeMode.light) {
      return ThemeMode.light;
    } else if (themeMode == SettingsThemeMode.dark) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }

  static String fromThemeMode(ThemeMode themeMode) {
    if (themeMode == ThemeMode.light) {
      return SettingsThemeMode.light;
    } else if (themeMode == ThemeMode.light) {
      return SettingsThemeMode.dark;
    } else {
      return SettingsThemeMode.system;
    }
  }
}
