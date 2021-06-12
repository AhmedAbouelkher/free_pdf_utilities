// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PdfPageFormatEnumAdapter extends TypeAdapter<PdfPageFormatEnum> {
  @override
  final int typeId = 11;

  @override
  PdfPageFormatEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PdfPageFormatEnum.A3;
      case 1:
        return PdfPageFormatEnum.A4;
      case 2:
        return PdfPageFormatEnum.A5;
      case 3:
        return PdfPageFormatEnum.Letter;
      default:
        return PdfPageFormatEnum.A3;
    }
  }

  @override
  void write(BinaryWriter writer, PdfPageFormatEnum obj) {
    switch (obj) {
      case PdfPageFormatEnum.A3:
        writer.writeByte(0);
        break;
      case PdfPageFormatEnum.A4:
        writer.writeByte(1);
        break;
      case PdfPageFormatEnum.A5:
        writer.writeByte(2);
        break;
      case PdfPageFormatEnum.Letter:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfPageFormatEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PageOrientationEnumAdapter extends TypeAdapter<PageOrientationEnum> {
  @override
  final int typeId = 22;

  @override
  PageOrientationEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PageOrientationEnum.Landscape;
      case 1:
        return PageOrientationEnum.Portrait;
      case 3:
        return PageOrientationEnum.Auto;
      default:
        return PageOrientationEnum.Landscape;
    }
  }

  @override
  void write(BinaryWriter writer, PageOrientationEnum obj) {
    switch (obj) {
      case PageOrientationEnum.Landscape:
        writer.writeByte(0);
        break;
      case PageOrientationEnum.Portrait:
        writer.writeByte(1);
        break;
      case PageOrientationEnum.Auto:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageOrientationEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ImageTypeAdapter extends TypeAdapter<ImageType> {
  @override
  final int typeId = 33;

  @override
  ImageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ImageType.PNG;
      case 1:
        return ImageType.JPG;
      default:
        return ImageType.PNG;
    }
  }

  @override
  void write(BinaryWriter writer, ImageType obj) {
    switch (obj) {
      case ImageType.PNG:
        writer.writeByte(0);
        break;
      case ImageType.JPG:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExportMethodAdapter extends TypeAdapter<ExportMethod> {
  @override
  final int typeId = 44;

  @override
  ExportMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExportMethod.Dart;
      case 1:
        return ExportMethod.Python;
      default:
        return ExportMethod.Dart;
    }
  }

  @override
  void write(BinaryWriter writer, ExportMethod obj) {
    switch (obj) {
      case ExportMethod.Dart:
        writer.writeByte(0);
        break;
      case ExportMethod.Python:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExportMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 0;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      themeMode: fields[0] as String?,
      exportOptions: fields[1] as PDFExportOptions?,
      pdfCompressionExportOptions: fields[2] as PDFCompressionExportOptions?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.exportOptions)
      ..writeByte(2)
      ..write(obj.pdfCompressionExportOptions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PDFExportOptionsAdapter extends TypeAdapter<PDFExportOptions> {
  @override
  final int typeId = 2;

  @override
  PDFExportOptions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PDFExportOptions(
      pageFormat: fields[0] as PdfPageFormatEnum?,
      pageOrientation: fields[1] as PageOrientationEnum?,
    );
  }

  @override
  void write(BinaryWriter writer, PDFExportOptions obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.pageFormat)
      ..writeByte(1)
      ..write(obj.pageOrientation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PDFExportOptionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PDFCompressionExportOptionsAdapter
    extends TypeAdapter<PDFCompressionExportOptions> {
  @override
  final int typeId = 3;

  @override
  PDFCompressionExportOptions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PDFCompressionExportOptions(
      level: fields[0] as int?,
      imageType: fields[1] as ImageType?,
      exportMethod: fields[2] as ExportMethod?,
    );
  }

  @override
  void write(BinaryWriter writer, PDFCompressionExportOptions obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.level)
      ..writeByte(1)
      ..write(obj.imageType)
      ..writeByte(2)
      ..write(obj.exportMethod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PDFCompressionExportOptionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
