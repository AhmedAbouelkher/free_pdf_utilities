import 'package:flutter/material.dart';
import 'package:free_pdf_utilities/Modules/Widgets/dropDown_listTile.dart';

import '../../settings_provider.dart';

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

    void _callOnSave([PDFExportOptions? exportOptions, PDFCompressionExportOptions? pdfCompressionExportOptions]) {
      onSave(
        AppSettings(
          exportOptions: exportOptions,
          pdfCompressionExportOptions: pdfCompressionExportOptions,
        ),
      );
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
            initialValue: _appSettings.exportOptions?.pageFormat ?? PdfPageFormatEnum.A4,
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
            initialValue: _appSettings.exportOptions?.pageOrientation ?? PageOrientationEnum.Portrait,
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
          subtitle: const Text(
            'Select PDF compression level (using Python)...',
            style: TextStyle(fontSize: 12),
          ),
          title: DropDownListTile<int>(
            title: "Compression Level",
            initialValue: _appSettings.pdfCompressionExportOptions?.level ?? CompressionLevel.level2,
            options: const [
              DropdownMenuItem(
                child: Text("Default"),
                value: CompressionLevel.level0,
              ),
              DropdownMenuItem(
                child: Text("Prepress"),
                value: CompressionLevel.level1,
              ),
              DropdownMenuItem(
                child: Text("Printer"),
                value: CompressionLevel.level2,
              ),
              DropdownMenuItem(
                child: Text("Ebook"),
                value: CompressionLevel.level3,
              ),
              DropdownMenuItem(
                child: Text("Screen"),
                value: CompressionLevel.level4,
              ),
            ],
            onChanged: (level) {
              _callOnSave(null, PDFCompressionExportOptions(level: level));
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
