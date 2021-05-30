import 'package:draggable_container/draggable_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';

import 'package:free_pdf_utilities/Modules/PDFServices/Providers/pdf_assets_controller.dart';
import 'package:free_pdf_utilities/Modules/Settings/settings_provider.dart';
import 'package:free_pdf_utilities/Modules/Widgets/dropDown_listTile.dart';
import 'package:free_pdf_utilities/Screens/root_screen.dart';

import 'package:provider/provider.dart';

class PNGtoPDFScreen extends StatefulWidget {
  @override
  _PNGtoPDFScreenState createState() => _PNGtoPDFScreenState();
}

class _PNGtoPDFScreenState extends State<PNGtoPDFScreen> {
  late final PDFAssetsController _assetsController;
  late final GlobalKey<DraggableContainerState<MyItem>> key;
  bool _isLoading = false;

  @override
  void initState() {
    _assetsController = PDFAssetsController();
    key = GlobalKey<DraggableContainerState<MyItem>>();

    super.initState();
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
        title: "PNG to PDF",
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
        onPressed: () => _assetsController.pickImages(),
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: StreamBuilder<List<PDFFile>>(
                stream: _assetsController.imageStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: Text("Start adding new images to convert..."));
                  }
                  final _images = snapshot.data!;
                  print(_images.length);

                  WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                    if (_images.isNotEmpty && !key.currentState!.editMode && mounted) {
                      key.currentState?.editMode = true;
                    }
                  });
                  return DraggableContainer<MyItem>(
                    key: key,
                    tapOutSideExitEditMode: false,
                    deleteButtonBuilder: (_, __) => const SizedBox(),
                    items: List.generate(_images.length, (index) {
                      return MyItem(index: index, deletable: true, fixed: false, pdfFile: _images[index]);
                    }),
                    itemBuilder: (context, rawItem) {
                      return PDFImageItem(
                        pdfFile: rawItem!.pdfFile,
                        onRemove: () {
                          key.currentState!.removeSlot(rawItem.index);
                        },
                      );
                    },
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 130,
                      childAspectRatio: 842 / 595,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    padding: const EdgeInsets.all(14.0),
                    beforeRemove: (item, slotIndex) async {
                      item = item as MyItem;
                      final res = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Remove item ${item!.index}?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
                            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
                          ],
                        ),
                      );
                      if (res == true) {
                        // key.currentState!.removeSlot(slotIndex);
                      }
                      return false;
                    },
                    onChanged: (items) {
                      print(items);
                    },
                  );
                  return CupertinoScrollbar(
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
            // onDelete();
          },
        ),
      ],
    );
  }

  Widget _renderExportPDFButton() {
    return StreamBuilder<List<PDFFile>>(
      stream: _assetsController.imageStream,
      builder: (context, snapshot) {
        final _images = snapshot.data ?? [];

        final bool _canExport = _images.isNotEmpty;

        void _exportPDF() async {
          if (_assetsController.isEmptyDocument) return;

          final _exportOptions = await showDialog(
            context: context,
            builder: (_) => _PDFExportDialog(),
          );
          if (_exportOptions == null) return;
          await Future.delayed(Duration(milliseconds: 300));
          setState(() => _isLoading = true);
          try {
            final _file = await _assetsController.generatePDFDocument(_exportOptions);
            setState(() => _isLoading = false);
            final _fileName = await _assetsController.exportPDFDocument(_file);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 4),
                content: Text.rich(
                  TextSpan(
                    text: "Saved to ",
                    children: [
                      TextSpan(text: "$_fileName", style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            );
          } catch (e) {
            print(e);
          } finally {
            if (_isLoading) setState(() => _isLoading = false);
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
  final PDFFile pdfFile;
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

class PDFImageItem extends StatefulWidget {
  final PDFFile pdfFile;
  final VoidCallback? onHoverStart;
  final VoidCallback? onHoverEnd;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onRemove;
  final VoidCallback? onPreview;

  const PDFImageItem({
    Key? key,
    required this.pdfFile,
    this.onHoverStart,
    this.onHoverEnd,
    this.onTap,
    this.onLongPress,
    this.onRemove,
    this.onPreview,
  }) : super(key: key);

  @override
  _PDFImageItemState createState() => _PDFImageItemState();
}

class _PDFImageItemState extends State<PDFImageItem> {
  bool _isHoverActive = false;

  void _onHoverStart() {
    widget.onHoverStart?.call();
  }

  void _onHoverEnd() {
    widget.onHoverEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        hoverColor: Colors.transparent,
        onTap: widget.onTap ?? () => null,
        onLongPress: widget.onLongPress,
        onHover: (value) {
          value ? _onHoverStart() : _onHoverEnd();
          setState(() => _isHoverActive = value);
        },
        child: Container(
          height: 210,
          width: 140,
          decoration: BoxDecoration(
            // color: _isHoverActive ? Colors.black : Colors.white,
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: _isHoverActive ? Colors.black : Colors.transparent,
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.file(widget.pdfFile.file.toFile()),
              ),
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: kDuration,
                  opacity: _isHoverActive ? 1.0 : 0.0,
                  // opacity: 1.0,
                  child: Visibility(
                    visible: _isHoverActive,
                    // visible: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: AnimatedContainer(
                      duration: kDuration,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.black45,
                      ),
                      child: _renderHoverContents(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderHoverContents() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 12.0, 5.0, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.pdfFile.name ?? "-",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: widget.onPreview,
                    child: const Text(
                      "Preview",
                      style: TextStyle(color: Colors.blue, fontSize: 11),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onRemove,
                    child: const Text(
                      "Remove",
                      style: TextStyle(color: Colors.red, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PDFExportDialog extends StatefulWidget {
  @override
  __PDFExportDialogState createState() => __PDFExportDialogState();
}

class __PDFExportDialogState extends State<_PDFExportDialog> {
  late PDFExportOptions _options;

  void _changeOptions(PDFExportOptions newOptions) {
    _options = _options.merge(newOptions);
    context.read<AppSettingsProvider>().saveSettings(AppSettings(exportOptions: _options));
  }

  @override
  Widget build(BuildContext context) {
    final _appSettings = context.watch<AppSettingsProvider>().appSettings();
    _options = _appSettings.exportOptions!;
    return AlertDialog(
      title: Text("Export PDF"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropDownListTile<PdfPageFormatEnum>(
            title: "Paper Size",
            initialValue: _options.pageFormat!,
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
            initialValue: _options.pageOrientation!,
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
          )
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

//
// responsive grid list
//

class ResponsiveGridList extends StatelessWidget {
  final double desiredItemWidth, minSpacing;
  final List<Widget> children;
  final bool squareCells, scroll;
  final MainAxisAlignment rowMainAxisAlignment;
  final EdgeInsetsGeometry? padding;

  ResponsiveGridList({
    required this.desiredItemWidth,
    this.padding,
    this.minSpacing = 1,
    this.squareCells = false,
    this.scroll = true,
    required this.children,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (children.length == 0) return Container();

        double width = constraints.maxWidth;

        double N = (width - minSpacing) / (desiredItemWidth + minSpacing);

        int n;
        double spacing, itemWidth;

        if (N % 1 == 0) {
          n = N.floor();
          spacing = minSpacing;
          itemWidth = desiredItemWidth;
        } else {
          n = N.floor();

          double dw = width - (n * (desiredItemWidth + minSpacing) + minSpacing);

          itemWidth = desiredItemWidth + (dw / n) * (desiredItemWidth / (desiredItemWidth + minSpacing));

          spacing = (width - itemWidth * n) / (n + 1);
        }

        if (scroll) {
          return ListView.builder(
              padding: padding ?? const EdgeInsets.symmetric(vertical: 20),
              itemCount: (children.length / n).ceil() * 2 - 1,
              itemBuilder: (context, index) {
                //if (index * n >= children.length) return null;
                //separator
                if (index % 2 == 1) {
                  return SizedBox(
                    height: minSpacing,
                  );
                }
                //item
                final rowChildren = <Widget>[];
                index = index ~/ 2;
                for (int i = index * n; i < (index + 1) * n; i++) {
                  if (i >= children.length) break;
                  rowChildren.add(children[i]);
                }
                return _ResponsiveGridListItem(
                  mainAxisAlignment: this.rowMainAxisAlignment,
                  itemWidth: itemWidth,
                  spacing: spacing,
                  squareCells: squareCells,
                  children: rowChildren,
                );
              });
        } else {
          final rows = <Widget>[];
          rows.add(SizedBox(
            height: minSpacing,
          ));
          //
          for (int j = 0; j < (children.length / n).ceil(); j++) {
            final rowChildren = <Widget>[];
            //
            for (int i = j * n; i < (j + 1) * n; i++) {
              if (i >= children.length) break;
              rowChildren.add(children[i]);
            }
            //
            rows.add(_ResponsiveGridListItem(
              mainAxisAlignment: this.rowMainAxisAlignment,
              itemWidth: itemWidth,
              spacing: spacing,
              squareCells: squareCells,
              children: rowChildren,
            ));

            rows.add(SizedBox(
              height: minSpacing,
            ));
          }

          return Column(
            children: rows,
          );
        }
      },
    );
  }
}

class _ResponsiveGridListItem extends StatelessWidget {
  final double spacing, itemWidth;
  final List<Widget> children;
  final bool squareCells;
  final MainAxisAlignment mainAxisAlignment;

  _ResponsiveGridListItem({
    required this.itemWidth,
    required this.spacing,
    required this.squareCells,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: this.mainAxisAlignment,
      children: _buildChildren(),
    );
  }

  List<Widget> _buildChildren() {
    final list = <Widget>[];

    list.add(SizedBox(
      width: spacing,
    ));

    children.forEach((child) {
      list.add(SizedBox(
        width: itemWidth,
        height: squareCells ? itemWidth : null,
        child: child,
      ));
      list.add(SizedBox(
        width: spacing,
      ));
    });

    return list;
  }
}
