import 'package:draggable_container/draggable_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_pdf_utilities/Modules/PDFServices/Widgets/pdf_image_item.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid/responsive_grid.dart';

import 'package:free_pdf_utilities/Modules/Settings/Screens/settings_screen.dart';
import 'package:free_pdf_utilities/Modules/Settings/settings_provider.dart';
import 'package:free_pdf_utilities/Modules/Widgets/dropDown_listTile.dart';
import 'package:free_pdf_utilities/Screens/root_screen.dart';

import '../pdf_assets_controller.dart';

//TODO: Impelement images multiselect
class PNGtoPDFScreen extends StatefulWidget {
  @override
  _PNGtoPDFScreenState createState() => _PNGtoPDFScreenState();
}

class _PNGtoPDFScreenState extends State<PNGtoPDFScreen> {
  late final PDFAssetsController _assetsController;
  AppSettingsProvider? _appSettingsProvider;
  bool _isLoading = false;

  @override
  void initState() {
    _assetsController = PDFAssetsController();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _appSettingsProvider!.generateTempExportOptions();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appSettingsProvider ??= context.read<AppSettingsProvider>();
  }

  // final key = GlobalKey<DraggableContainerState<MyItem>>();

  @override
  void dispose() {
    _assetsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAppBar(
        title: "Images to PDF",
        leading: [
          IconButton(
            onPressed: () {
              if (_assetsController.isEmptyDocument) return Navigator.pop(context);
              showDialog(context: context, builder: (_) => _renderDismissAlertDialog());
            },
            splashRadius: 15,
            iconSize: 15,
            icon: BackButtonIcon(),
          ),
        ],
        actions: [
          _renderExportPDFButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _assetsController.pickFiles();

          ///Called when picking new file to generate new temp export options.
          _appSettingsProvider?.generateTempExportOptions();
        },
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: StreamBuilder<List<CxFile>>(
                stream: _assetsController.imageStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: Text("Start adding new images to convert..."));
                  }
                  final _images = snapshot.data!;

                  return Scrollbar(
                    // thickness: 50,
                    // radius: Radius.circular(50),
                    isAlwaysShown: true,
                    child: ResponsiveGridList(
                      desiredItemWidth: 140,
                      minSpacing: 15,
                      children: List.generate(
                        _images.length,
                        (index) {
                          final _image = _images[index];
                          return PDFImageItem(
                            pdfFile: _image,
                            onRemove: () async {
                              final _result = await showDialog<bool>(
                                context: context,
                                builder: (_) => _renderPageRemovalAlertDialog(_image.name ?? "-"),
                              );
                              if (_result ?? false) _assetsController.removeAt(index);
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
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

  Widget _renderPageRemovalAlertDialog(String name) {
    return AlertDialog(
      title: const Text("Are you sure you want to remove this page?"),
      content: Text("You are going to remove '$name' permanently..."),
      buttonPadding: const EdgeInsets.all(15),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Remove", style: TextStyle(color: Colors.red)),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }

  Widget _renderDismissAlertDialog() {
    return AlertDialog(
      title: const Text("Are you sure you want to discard changes?"),
      content: Text('This will remove all your pregress so far.'),
      buttonPadding: const EdgeInsets.all(15),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Confirm", style: TextStyle(color: Colors.red)),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _renderExportPDFButton() {
    return StreamBuilder<List<CxFile>>(
      stream: _assetsController.imageStream,
      builder: (context, snapshot) {
        final _images = snapshot.data ?? [];

        final bool _canExport = _images.isNotEmpty;

        void _exportPDF() async {
          if (_assetsController.isEmptyDocument) return;

          final _exportOptions = await showDialog<PDFExportOptions>(
            context: context,
            builder: (_) => _PDFExportDialog(
              onSave: (exportOptions) {
                _appSettingsProvider!.updateTempExportOptions(exportOptions);
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
            final _file = await _assetsController.generateDoument(_exportOptions);
            setState(() => _isLoading = false);
            final _filePath = await _assetsController.exportDocument(_file);
            _assetsController.showInFinder(_filePath, context);
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

class MyItem extends DraggableItem {
  final Color? color;
  final int index;
  final CxFile pdfFile;
  bool deletable;
  bool fixed;

  MyItem({
    this.color = Colors.black,
    required this.index,
    required this.pdfFile,
    required this.deletable,
    required this.fixed,
  });

  @override
  String toString() {
    return 'MyItem(index:$index)';
  }
}

class _PDFExportDialog extends StatelessWidget {
  final ValueChanged<PDFExportOptions> onSave;
  final VoidCallback? onOpenSettings;
  const _PDFExportDialog({
    Key? key,
    required this.onSave,
    this.onOpenSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _settingsProvider = context.read<AppSettingsProvider>();
    final _appSettings = _settingsProvider.appSettings();
    final _tempExportOptions = _settingsProvider.readTempExportOptions<PDFExportOptions>();

    final _options = (_tempExportOptions ?? _appSettings.exportOptions) ?? const PDFExportOptions();

    void _changeOptions(PDFExportOptions newOptions) {
      final _newOptions = _options.merge(newOptions);
      onSave(_newOptions);
    }

    return AlertDialog(
      title: Text("Export PDF"),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropDownListTile<PdfPageFormatEnum>(
            title: "Paper Size",
            initialValue: _options.pageFormat ?? PdfPageFormatEnum.A4,
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
              _changeOptions(PDFExportOptions(pageFormat: pageFormate));
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Divider(),
          ),
          DropDownListTile<PageOrientationEnum>(
            title: "Layout",
            initialValue: _options.pageOrientation ?? PageOrientationEnum.Portrait,
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
              _changeOptions(PDFExportOptions(pageOrientation: pageOrientation));
            },
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                onOpenSettings?.call();
              },
              child: Text(
                "Change defaults...",
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
        ],
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
            "Export",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.of(context).pop(_options),
        ),
      ],
    );
  }
}

                  // WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                  //   if (_images.isNotEmpty && !key.currentState!.editMode && mounted) {
                  //     key.currentState?.editMode = true;
                  //   }
                  // });
                  // return DraggableContainer<MyItem>(
                  //   key: key,
                  //   tapOutSideExitEditMode: false,
                  //   deleteButtonBuilder: (_, __) => const SizedBox(),
                  //   items: List.generate(_images.length, (index) {
                  //     return MyItem(index: index, deletable: true, fixed: false, pdfFile: _images[index]);
                  //   }),
                  //   itemBuilder: (context, rawItem) {
                  //     return PDFImageItem(
                  //       pdfFile: rawItem!.pdfFile,
                  //       onRemove: () {
                  //         key.currentState!.removeSlot(rawItem.index);
                  //       },
                  //     );
                  //   },
                  //   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  //     maxCrossAxisExtent: 130,
                  //     childAspectRatio: 842 / 595,
                  //     crossAxisSpacing: 10,
                  //     mainAxisSpacing: 10,
                  //   ),
                  //   padding: const EdgeInsets.all(14.0),
                  //   beforeRemove: (item, slotIndex) async {
                  //     item = item as MyItem;
                  //     final res = await showDialog<bool>(
                  //       context: context,
                  //       builder: (_) => AlertDialog(
                  //         title: Text('Remove item ${item!.index}?'),
                  //         actions: [
                  //           TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
                  //           ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
                  //         ],
                  //       ),
                  //     );
                  //     if (res == true) {
                  //       // key.currentState!.removeSlot(slotIndex);
                  //     }
                  //     return false;
                  //   },
                  //   onChanged: (items) {
                  //     print(items);
                  //   },
                  // );