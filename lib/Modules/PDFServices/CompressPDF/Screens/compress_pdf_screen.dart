import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_pdf_utilities/Modules/PDFServices/CompressPDF/pdf_compression_controller.dart';
import 'package:free_pdf_utilities/Modules/PDFServices/PNG_TO_PDF/pdf_assets_controller.dart';
import 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';
import 'package:free_pdf_utilities/Modules/Settings/Screens/settings_screen.dart';
import 'package:free_pdf_utilities/Modules/Settings/settings_provider.dart';
import 'package:free_pdf_utilities/Modules/Widgets/dropDown_listTile.dart';
import 'package:free_pdf_utilities/Screens/root_screen.dart';

//TODO: Finish setting up Compressed PDF export.

class CompressPDFScreen extends StatefulWidget {
  const CompressPDFScreen({Key? key}) : super(key: key);

  @override
  _CompressPDFScreenState createState() => _CompressPDFScreenState();
}

class _CompressPDFScreenState extends State<CompressPDFScreen> {
  late PDFCompressionController _pdfCompressionController;
  bool _isLoading = false;
  @override
  void initState() {
    _pdfCompressionController = PDFCompressionController();
    super.initState();
  }

  @override
  void dispose() {
    _pdfCompressionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CAppBar(
        title: "Compress PDF",
        leading: [
          IconButton(
            onPressed: () {
              // if (_assetsController.isEmptyDocument) return Navigator.pop(context);
              // showDialog(context: context, builder: (_) => _renderDismissAlertDialog());
              Navigator.pop(context);
            },
            splashRadius: 15,
            iconSize: 15,
            icon: BackButtonIcon(),
          ),
        ],
        actions: [_renderExportPDFButton()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pdfCompressionController.pickFiles(),
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Center(
          child: StreamBuilder<CxFile>(
              stream: _pdfCompressionController.pdfFileStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text("Pick you PDF file...");
                }
                final _file = snapshot.data!;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.doc_richtext, size: _size.height / 2),
                    SizedBox(height: 30),
                    Text(_file.name!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    SizedBox(height: 20),
                    Text(_file.updatedAt?.toIso8601String() ?? "-"),
                    Text(_file.fileSize ?? "-")
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget _renderExportPDFButton() {
    return StreamBuilder<CxFile>(
      stream: _pdfCompressionController.pdfFileStream,
      builder: (context, snapshot) {
        final bool _canExport = snapshot.hasData;

        void _exportPDF() async {
          // if (_assetsController.isEmptyDocument) return;

          final _exportOptions = await showDialog<ExportOptions>(
            context: context,
            builder: (_) => _PDFExportDialog(
              onSave: (exportOptions) {
                // _appSettingsProvider!.updateTempExportOptions(exportOptions);
              },
              onOpenSettings: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      settingsTap: SettingsTap.ExportOptions,
                    ),
                  ),
                );
              },
            ),
          );
          if (_exportOptions == null) return;
          setState(() => _isLoading = true);

          try {
            // final _file = await _assetsController.generateDoument(_exportOptions);
            setState(() => _isLoading = false);
            // final _filePath = await _assetsController.exportDocument(_file);
            // _showOnFinder(_filePath);
          } catch (e) {
            print(e);
          } finally {
            if (_isLoading && mounted) setState(() => _isLoading = false);
          }
        }

        return IconButton(
          splashRadius: 15,
          onPressed: !_canExport ? null : _exportPDF,
          icon: Icon(CupertinoIcons.tray_arrow_up_fill),
          iconSize: 18,
        );
      },
    );
  }
}

class _PDFExportDialog extends StatefulWidget {
  final ValueChanged<PDFExportOptions> onSave;
  final VoidCallback? onOpenSettings;
  const _PDFExportDialog({
    Key? key,
    required this.onSave,
    this.onOpenSettings,
  }) : super(key: key);

  @override
  __PDFExportDialogState createState() => __PDFExportDialogState();
}

class __PDFExportDialogState extends State<_PDFExportDialog> {
  bool _isAdvanced = false;
  @override
  Widget build(BuildContext context) {
    final _settingsProvider = context.read<AppSettingsProvider>();
    final _appSettings = _settingsProvider.appSettings();
    final _tempExportOptions = _settingsProvider.readTempExportOptions<PDFExportOptions>();

    final _options = (_tempExportOptions ?? _appSettings.exportOptions) ?? const PDFExportOptions();

    void _changeOptions(PDFExportOptions newOptions) {
      final _newOptions = _options.merge(newOptions);
      widget.onSave(_newOptions);
    }

    return AlertDialog(
      title: Text("Compress PDF"),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0.0),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "Recommended Settings.",
                style: TextStyle(fontSize: 12),
              ),
              value: false,
              groupValue: _isAdvanced,
              onChanged: (value) {
                setState(() => _isAdvanced = value!);
              },
            ),
            RadioListTile<bool>(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "Nerds' Settings.",
                style: TextStyle(fontSize: 12),
              ),
              value: true,
              groupValue: _isAdvanced,
              onChanged: (value) {
                setState(() => _isAdvanced = value!);
              },
            ),
            if (_isAdvanced) ...[
              Divider(),
              SizedBox(height: 10),
              _renderAdvancedSettings(),
              SizedBox(height: 10),
            ],
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // onOpenSettings?.call();
                },
                child: Text(
                  "Change defaults...",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
      buttonPadding: const EdgeInsets.all(15),
      actions: [
        TextButton(
          child: const Text(
            "Cancel",
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text(
            "Compress",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.of(context).pop(_options),
        ),
      ],
    );
  }

  Widget _renderAdvancedSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          _renderDartOptions(),
        ],
      ),
    );
  }

  Widget _renderDartOptions() {
    return Column(
      children: [
        _RadioOption(
          title: "Pure Dart Compression (Not optimized)",
          value: false,
          onChecked: (value) {},
          groupValue: false,
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 10),
          child: Column(
            children: [
              DropDownListTile<PdfPageFormatEnum>(
                title: "Paper Size",
                initialValue: PdfPageFormatEnum.A4,
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
                  // _changeOptions(PDFExportOptions(pageFormat: pageFormate));
                },
              ),
              SizedBox(height: 5),
              DropDownListTile<PdfPageFormatEnum>(
                enabled: false,
                title: "Paper Size",
                initialValue: PdfPageFormatEnum.A4,
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
                  // _changeOptions(PDFExportOptions(pageFormat: pageFormate));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckBoxOption extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChecked;
  final bool enabled;
  const _CheckBoxOption({
    Key? key,
    this.enabled = true,
    required this.title,
    required this.value,
    required this.onChecked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            constraints: BoxConstraints(maxWidth: _size.width / 2.0, minWidth: 0),
            child: Text(
              title,
              style: TextStyle(fontSize: 12, color: !enabled ? Colors.white60 : null),
            ),
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: value,
            onChanged: !enabled ? null : (value) => onChecked(value!),
          ),
        ),
      ],
    );
  }
}

class _RadioOption<T> extends StatelessWidget {
  final String title;
  final T value;
  final T groupValue;
  final ValueChanged<T> onChecked;
  final bool enabled;
  const _RadioOption({
    this.enabled = true,
    Key? key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChecked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        onChecked(value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Radio<T>(
                value: value,
                groupValue: groupValue,
                onChanged: !enabled ? null : (value) => onChecked(value!),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxWidth: _size.width / 2.0, minWidth: 0),
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, color: !enabled ? Colors.white60 : null),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



              // for (var i = 0; i < 30; i++) ...[
              //   Center(
              //       child: SizedBox(
              //           height: 15.0 * i,
              //           width: 15.0 * i,
              //           child: CircularProgressIndicator(
              //             valueColor: AlwaysStoppedAnimation<Color>(Colors.red.withAlpha(i.isEven ? 150 : 255)),
              //           ))),
              //   Center(
              //       child: SizedBox(
              //           height: 18.0 * i,
              //           width: 18.0 * i,
              //           child: CircularProgressIndicator(
              //             valueColor: AlwaysStoppedAnimation<Color>(Colors.red.withAlpha(i.isEven ? 250 : 60)),
              //           ))),
              //   Center(
              //     child: CupertinoActivityIndicator(
              //       animating: true,
              //       radius: 20,
              //     ),
              //   )
              // ]

        // onPressed: () async {
        //   final docs = await getApplicationDocumentsDirectory();
        //   var _testPath = join(docs.path, 'test_compression/');
        //   final _filePath = join(_testPath, 'origin.pdf');
        //   final XFile _originSizeFile = XFile(_filePath);
        //   // try {
        //   // final _new = await CompressionCLController.compress(XFile(_filePath).toCxFile());
        //   //   print(_new.path);
        //   // } catch (e) {
        //   //   log(e.toString());
        //   // }
        //   final _fileSizeBefore = filesize((await _originSizeFile.readAsBytes()).length);
        //   print(_fileSizeBefore);

        //   final _compressedFile = await _pdfCompressionController.generateDoument(
        //       PDFCompressionExportOptions(compression: 80), _originSizeFile.toCxFile());

        //   final _fileSizeAfter = filesize((await _compressedFile.readAsBytes()).length);
        //   print(_fileSizeAfter);

        //   final _saveToPath = join((await CompressionCLController.tempPDFGeneratingDirectory()).path, 'gen.pdf');
        //   await _compressedFile.saveTo(_saveToPath);

        //   print(_saveToPath);
        //   print("Done");
        // },