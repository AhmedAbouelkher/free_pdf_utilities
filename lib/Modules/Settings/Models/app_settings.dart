import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:free_pdf_utilities/Modules/Common/Utils/Models/assets_controller.dart';
import 'package:free_pdf_utilities/Modules/PDFServices/PNG_TO_PDF/pdf_assets_controller.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 0)
class AppSettings {
  @HiveField(0)
  final String? themeMode;

  @HiveField(1)
  final PDFExportOptions? exportOptions;

  @HiveField(2)
  final PDFCompressionExportOptions? pdfCompressionExportOptions;

  const AppSettings({
    this.themeMode,
    this.exportOptions,
    this.pdfCompressionExportOptions,
  });

  AppSettings copyWith({
    String? themeMode,
    PDFExportOptions? exportOptions,
    PDFCompressionExportOptions? pdfCompressionExportOptions,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      exportOptions: exportOptions ?? this.exportOptions,
      pdfCompressionExportOptions: pdfCompressionExportOptions ?? this.pdfCompressionExportOptions,
    );
  }

  AppSettings merge(AppSettings? other) {
    if (other == null) return this;
    return copyWith(
      themeMode: other.themeMode,
      exportOptions: (this.exportOptions ?? const PDFExportOptions()).merge(other.exportOptions),
      pdfCompressionExportOptions: (this.pdfCompressionExportOptions ?? const PDFCompressionExportOptions())
          .merge(other.pdfCompressionExportOptions),
    );
  }

  @override
  String toString() => 'AppSettings(themeMode: $themeMode, exportOptions: $exportOptions)';
}

@HiveType(typeId: 33)
class Nothing {}

@HiveType(typeId: 11)
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

@HiveType(typeId: 22)
enum PageOrientationEnum {
  @HiveField(0)
  Landscape,
  @HiveField(1)
  Portrait
}

@HiveType(typeId: 2)
class PDFExportOptions extends ExportOptions {
  @HiveField(0)
  final PdfPageFormatEnum? pageFormat;
  @HiveField(1)
  final PageOrientationEnum? pageOrientation;

  const PDFExportOptions({
    this.pageFormat,
    this.pageOrientation,
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

@HiveType(typeId: 3)
class PDFCompressionExportOptions extends ExportOptions {
  ///Compression value between `50%` to `100%`.
  @HiveField(0)
  final int? compression;

  const PDFCompressionExportOptions({
    this.compression,
  });

  PDFCompressionExportOptions copyWith({
    int? compression,
  }) {
    return PDFCompressionExportOptions(
      compression: compression ?? this.compression,
    );
  }

  PDFCompressionExportOptions merge(PDFCompressionExportOptions? other) {
    if (other == null) return this;
    return copyWith(
      compression: other.compression,
    );
  }

  @override
  String toString() => 'PDFCompressionExportOptions(compression: $compression)';
}

class SettingsThemeMode {
  static const light = 'light';
  static const dark = 'dark';
  static const system = 'system';

  const SettingsThemeMode();

  static ThemeMode getThemeMode(String? themeMode) {
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

PdfPageFormat? getPdfPageFormat(PdfPageFormatEnum? pageFormatEnum) {
  if (pageFormatEnum == null) return null;
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

pw.PageOrientation? getPageOrientation(PageOrientationEnum? pageOrientationEum) {
  if (pageOrientationEum == null) return null;
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
