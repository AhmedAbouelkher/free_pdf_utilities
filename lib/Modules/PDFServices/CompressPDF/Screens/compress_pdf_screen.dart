import 'dart:ui';

import 'package:date_time_format/date_time_format.dart';
import 'package:file_selector/file_selector.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import 'package:free_pdf_utilities/Modules/Common/Utils/Notifiers/toasts.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';
import 'package:free_pdf_utilities/Modules/PDFServices/CompressPDF/pdf_compression_controller.dart';
import 'package:free_pdf_utilities/Modules/PDFServices/PNG_TO_PDF/pdf_assets_controller.dart';
import 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';
import 'package:free_pdf_utilities/Modules/Settings/Screens/Settings/settings_screen.dart';
import 'package:free_pdf_utilities/Modules/Settings/settings_provider.dart';
import 'package:free_pdf_utilities/Modules/Widgets/clipboard_icon_button.dart';
import 'package:free_pdf_utilities/Modules/Widgets/custom_app_bar.dart';
import 'package:free_pdf_utilities/Modules/Widgets/dropDown_listTile.dart';
import 'package:free_pdf_utilities/Modules/Widgets/hint_screen.dart';
import 'package:free_pdf_utilities/Modules/Widgets/platform_items_switcher.dart';

//TODO: Refactor this screen
//TODO: [Feature] add drag and drop functionality. (see: desktop_drop_test-master project)
//TODO: [Feature] add `show in finder` on macOS. (see: desktop_drop_test-master project)

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
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      context.read<PythonCompressionControllerNotifier>()
        ..init(_pdfCompressionController)
        ..checkDependencies();
    });
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

  Future<XFile?> _handleFileCompression(PDFCompressionExportOptions options) async {
    XFile? _file;
    try {
      _file = await _pdfCompressionController.generateDocument(options);
    } on NotSupportedPlatform catch (e) {
      notifyError(e.message);
    } on GhostScriptNotInstalled {
      notifyError("$kAppName needs GhostScript to be installed to enable this feature");
    } on PythonNotInstalled {
      notifyError("$kAppName needs Python SDK to be installed to enable this feature");
    } on PDFRasterNotSupported {
      notifyError("$kAppName doesn't support this feature on the current platform, yet");
    } on InvalidFile {
      notifyError("The selected file is in invalid formate, make sure you selected files with extensions .pdf");
    } on UnknownPythonCompressionException catch (e) {
      notifyError("Error while running Python Script ${e.error!.message}");
    } catch (error) {
      notifyError(error.toString());
    }
    return _file;
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
                      return ToolHintScreen(
                        assetPath: Assets.attachedFileSVG,
                        title: "Choose a PDF file from your file system...",
                      );
                    }
                    final _file = snapshot.data!;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon(CupertinoIcons.doc_richtext, size: _size.height / 2),
                        SvgPicture.asset(
                          Assets.myFilesSVG,
                          height: _size.height / 2.5,
                        ),
                        SizedBox(height: 30),
                        Text(_file.name!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        SizedBox(height: 20),
                        Text(_file.updatedAt?.format(r'j M Y @ g:i a') ?? "-"),
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
            final _file = await _handleFileCompression(_exportOptions);

            _finishedProcess();
            if (_file == null) return;

            final _export = await showDialog<bool>(
              context: context,
              builder: (_) => _CompressionSummeryDialog(
                summery: _pdfCompressionController.compressionSummery!,
              ),
            );
            if (_export == null) return;

            final _filePath = await _pdfCompressionController.exportDocument(_file);

            _pdfCompressionController.showInFinder(_filePath, context);
          } on UserCancelled {} catch (e) {
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
  void initState() {
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   context.read<PythonCompressionControllerNotifier>().checkDependices();
    // });
    super.initState();
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
            Consumer<PythonCompressionControllerNotifier>(
              builder: (context, provider, _) {
                return RadioListTile<bool>(
                  onChanged: (value) => setState(() => _isAdvanced = value!),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    "Default Export Settings. (Recommended)",
                    style: TextStyle(fontSize: 12),
                  ),
                  value: false,
                  groupValue: _isAdvanced,
                  subtitle: _isAdvanced ? null : _dependencesAvailabilitySubtitle(provider),
                );
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
        PlatformItemsSwitcher(
          children: [
            Consumer<PythonCompressionControllerNotifier>(
              builder: (context, provider, _) {
                return TextButton(
                  child: const Text(
                    "Compress",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: !provider.isAllServicesAvailable ? null : () => Navigator.of(context).pop(_options),
                );
              },
            ),
            PlatformItemsSwitcher.actionsSpace(),
            TextButton(
              child: const Text(
                "Cancel",
                // style: TextStyle(fontWeight: FontWeight.normal),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        )
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
    final _provider = context.watch<PythonCompressionControllerNotifier>();
    return _RadioOption<ExportMethod>(
      title: "Python Compression",
      value: ExportMethod.Python,
      groupValue: (_options as PDFCompressionExportOptions).exportMethod ?? ExportMethod.Python,
      onChecked: (exportMethod) {
        _changeOptions(PDFCompressionExportOptions(exportMethod: exportMethod));
      },
      details: _dependencesAvailabilitySubtitle(_provider),
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

  Widget? _dependencesAvailabilitySubtitle(PythonCompressionControllerNotifier provider) {
    if (provider.isAllServicesAvailable) return null;
    final TextStyle _style = TextStyle(
      fontSize: 11,
      color: Colors.redAccent,
    );

    Widget _errorWidget(VoidCallback onTap, String title, String btnTitle, {String? tip}) {
      return Row(
        children: [
          Text(
            title,
            style: _style,
          ),
          SizedBox(width: 5),
          Tooltip(
            message: tip ?? btnTitle,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                child: Text(
                  btnTitle,
                  style: _style.copyWith(color: Colors.blue),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!provider.isPythonAvailable)
                _errorWidget(
                  () {
                    urlLauncher.launch(kPythonDownload);
                  },
                  "Python is not installed",
                  "Install",
                  tip: "Install Python from python.org",
                ),
              if (!provider.isGhostScriptAvailable)
                _errorWidget(
                  () {
                    showDialog(
                        context: context,
                        builder: (_) {
                          return _InstallGhostScriptlertDialog();
                        });
                  },
                  "GhostScript is not installed",
                  "Install",
                  tip: "Install GhostScript",
                ),
            ],
          ),
          SizedBox(width: 10),
          IconButton(
            constraints: BoxConstraints(),
            tooltip: "Refresh",
            splashRadius: 15,
            iconSize: 15,
            icon: Icon(Icons.replay),
            onPressed: () {
              provider.checkDependencies();
            },
          ),
        ],
      ),
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
        '''Because the Dart compression algorithm effeicency is too low, using it is disabled right now.'''
        '''\n'''
        '''If you beleive you can help us to create a powerful algorithm, create a new PR.''',
      ),
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

class _InstallGhostScriptlertDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Install GhostScript for your system"),
      // contentPadding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 10, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText("$kAppName needs to install dependency Ghostscript"),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // SelectableText("On MacOSX: brew install ghostscript."),
              SelectableText.rich(TextSpan(text: "On MacOSX: ", children: [
                TextSpan(text: "run"),
                TextSpan(
                  text: " brew install ghostscript ",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                TextSpan(text: "in terminal"),
              ])),
              ClipboardIconButton(
                text: "brew install ghostscript",
              )
            ],
          ),
          SelectableText("On Windows/Linux: install binaries via official website."),
        ],
      ),
      actions: [
        TextButton.icon(
          icon: Icon(FontAwesomeIcons.github, color: Colors.white),
          label: const Text(
            "Go to Official Website",
            style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            urlLauncher.launch(kGhostScriptDownload);
          },
        ),
      ],
    );
  }
}

class _CompressionSummeryDialog extends StatelessWidget {
  final CompressionSummery summery;
  const _CompressionSummeryDialog({
    Key? key,
    required this.summery,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: const Text("Compression Summery")),
      contentPadding: const EdgeInsets.all(20.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              Text("Compression by"),
              Text(
                "${summery.reduction.round().toString()}%",
                style: TextStyle(fontSize: 50),
              ),
            ],
          ),
          SizedBox(height: 20),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Original Size: ${filesize(summery.originalSize.toInt())}"),
                Text("Compressed Size: ${filesize(summery.compressionSize.toInt())}"),
              ],
            ),
          ),
        ],
      ),
      actions: [
        PlatformItemsSwitcher(
          children: [
            Consumer<PythonCompressionControllerNotifier>(
              builder: (context, provider, _) {
                return TextButton(
                  child: const Text(
                    "Export",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                );
              },
            ),
            PlatformItemsSwitcher.actionsSpace(),
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
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
                details ?? const SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
