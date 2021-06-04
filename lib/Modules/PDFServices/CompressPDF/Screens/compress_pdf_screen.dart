import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;
import 'package:free_pdf_utilities/Modules/PDFServices/CompressPDF/pdf_compression_controller.dart';
import 'package:free_pdf_utilities/Modules/PDFServices/PNG_TO_PDF/pdf_assets_controller.dart';
import 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';
import 'package:free_pdf_utilities/Modules/Settings/Screens/settings_screen.dart';
import 'package:free_pdf_utilities/Modules/Settings/settings_provider.dart';
import 'package:free_pdf_utilities/Modules/Widgets/dropDown_listTile.dart';
import 'package:free_pdf_utilities/Screens/root_screen.dart';

//TODO: Show dialog to show compression summary
//TODO: handle compression exceptions

class CompressPDFScreen extends StatefulWidget {
  const CompressPDFScreen({Key? key}) : super(key: key);

  @override
  _CompressPDFScreenState createState() => _CompressPDFScreenState();
}

class _CompressPDFScreenState extends State<CompressPDFScreen> {
  late PDFCompressionController _pdfCompressionController;
  AppSettingsProvider? _appSettingsProvider;
  bool _isLoading = false;

  @override
  void initState() {
    _pdfCompressionController = PDFCompressionController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appSettingsProvider ??= context.read<AppSettingsProvider>();
  }

  @override
  void dispose() {
    _pdfCompressionController.dispose();
    super.dispose();
  }

  void _inProgress() {
    setState(() => _isLoading = true);
  }

  void _finishedProcess() {
    if (_isLoading && mounted) setState(() => _isLoading = false);
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
        onPressed: () async {
          await _pdfCompressionController.pickFiles();

          ///Called when picking new file to generate new temp export options.
          _appSettingsProvider?.generateTempExportOptions();
        },
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
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
            if (_isLoading) ...[
              Positioned.fill(child: Container(color: Colors.black54)),
              Center(child: CircularProgressIndicator.adaptive()),
            ]
          ],
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
          final _exportOptions = await showDialog<PDFCompressionExportOptions>(
            context: context,
            builder: (_) => _PDFExportDialog(
              onSave: (exportOptions) async {
                final _appSettings = AppSettings(pdfCompressionExportOptions: exportOptions);
                _appSettingsProvider!.updateSettings(_appSettings);
                await _appSettingsProvider!.updateTempExportOptions(exportOptions);
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
          _inProgress();

          try {
            final _file = await _pdfCompressionController.generateDoument(_exportOptions);
            _finishedProcess();
            final _filePath = await _pdfCompressionController.exportDocument(_file);
            _pdfCompressionController.showInFinder(_filePath, context);
          } catch (e) {
            print(e);
          } finally {
            _finishedProcess();
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
  final ValueChanged<PDFCompressionExportOptions> onSave;
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
  late AppSettingsProvider _settingsProvider;
  late ExportOptions _options;

  void _changeOptions(PDFCompressionExportOptions newOptions) {
    final _newOptions = (_options as PDFCompressionExportOptions).merge(newOptions);
    widget.onSave(_newOptions);
  }

  @override
  Widget build(BuildContext context) {
    _settingsProvider = context.watch<AppSettingsProvider>();
    final _appSettings = _settingsProvider.appSettings();
    final _tempExportOptions = _settingsProvider.readTempExportOptions<PDFCompressionExportOptions>();
    _options = (_tempExportOptions ?? _appSettings.pdfCompressionExportOptions) ?? const PDFCompressionExportOptions();
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
                "Default Export Settings. (Recommended)",
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
                "Nerds' Export Settings.",
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
                  widget.onOpenSettings?.call();
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
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 10),
            child: DropDownListTile<int>(
              title: "Compression Level",
              initialValue: (_options as PDFCompressionExportOptions).level ?? CompressionLevel.level2,
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
                _changeOptions(PDFCompressionExportOptions(level: level));
              },
            ),
          ),
          // SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Divider(),
          ),
          _renderPythonOptions(),
          _renderDartOptions(),
        ],
      ),
    );
  }

  Widget _renderPythonOptions() {
    return _RadioOption<ExportMethod>(
      title: "Python Compression",
      value: ExportMethod.Python,
      groupValue: (_options as PDFCompressionExportOptions).exportMethod ?? ExportMethod.Python,
      onChecked: (exportMethod) {
        _changeOptions(PDFCompressionExportOptions(exportMethod: exportMethod));
      },
    );
  }

  Widget _renderDartOptions() {
    final _exportMethod = (_options as PDFCompressionExportOptions).exportMethod ?? ExportMethod.Python;
    return Column(
      children: [
        _RadioOption<ExportMethod>(
          enabled: false,
          title: "Pure Dart Compression (!optimized)",
          value: ExportMethod.Dart,
          groupValue: _exportMethod,
          onChecked: (exportMethod) {
            _changeOptions(PDFCompressionExportOptions(exportMethod: exportMethod));
          },
          details: TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return _DartCompressionDisableAlertDialog();
                  });
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Learn more",
              style: TextStyle(fontSize: 10),
            ),
          ),
        ),
        if (_exportMethod == ExportMethod.Dart) ...[
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 10),
            child: DropDownListTile<ImageType>(
              title: "Image Type",
              initialValue: (_options as PDFCompressionExportOptions).imageType ?? ImageType.PNG,
              options: const [
                DropdownMenuItem(
                  child: Text("PNG"),
                  value: ImageType.PNG,
                ),
                DropdownMenuItem(
                  child: Text("JPEG/JPG"),
                  value: ImageType.JPG,
                ),
              ],
              onChanged: (imageType) {
                _changeOptions(PDFCompressionExportOptions(imageType: imageType));
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _DartCompressionDisableAlertDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Pure Dart Compression is disabled"),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0.0),
      content: Text(
          '''Due to the low effeicency of the Dart compression algorithm the opetion to enable it is disabled right now.\n\n'''
          '''If you beleive you can help us to create a powerfull algorithm, create a new PR.'''),
      actions: [
        TextButton.icon(
          icon: Icon(FontAwesomeIcons.github, color: Colors.white),
          label: const Text(
            "Go to Github",
            style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            urlLauncher.launch(kAppRepo);
          },
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
  final Widget? details;
  const _RadioOption({
    Key? key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChecked,
    this.enabled = true,
    this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    var _color = !enabled ? Colors.transparent : null;
    return InkWell(
      splashColor: _color,
      highlightColor: _color,
      hoverColor: _color,
      onTap: () {
        if (enabled) onChecked(value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: details == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: _size.width / 2.0, minWidth: 0),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 12, color: !enabled ? Colors.white60 : null),
                  ),
                ),
                details ?? SizedBox(),
              ],
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