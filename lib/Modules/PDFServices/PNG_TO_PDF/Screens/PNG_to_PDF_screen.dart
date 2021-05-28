import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:free_pdf_utilities/Modules/PDFServices/Providers/pdf_assets_controller.dart';
import 'package:free_pdf_utilities/Screens/root_screen.dart';

class PNGtoPDFScreen extends StatefulWidget {
  @override
  _PNGtoPDFScreenState createState() => _PNGtoPDFScreenState();
}

class _PNGtoPDFScreenState extends State<PNGtoPDFScreen> {
  late PDFAssetsController _assetsController;

  bool _isLoading = false;

  @override
  void initState() {
    _assetsController = PDFAssetsController();
    super.initState();
  }

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
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
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
                ),
              );
            },
            splashRadius: 15,
            icon: BackButtonIcon(),
          ),
        ],
        actions: [
          _renderExportPDFButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _assetsController.pickImages();
        },
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: StreamBuilder<List<XFile>>(
                stream: _assetsController.imageStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: Text("Start adding new images to convert..."));
                  }
                  final _images = snapshot.data!.map((e) => e.toFile()).toList();
                  return CupertinoScrollbar(
                    // thickness: 50,
                    // radius: Radius.circular(50),
                    isAlwaysShown: true,
                    child: ResponsiveGridList(
                      desiredItemWidth: 148,
                      minSpacing: 10,
                      children: List.generate(
                        _images.length,
                        (index) {
                          final _image = _images[index];
                          return InkWell(
                            onLongPress: () {
                              _assetsController.removeAt(index);
                            },
                            enableFeedback: true,
                            excludeFromSemantics: true,
                            onHover: (value) {},
                            child: Container(
                              height: 210,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Image.file(_image),
                            ),
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

  Widget _renderExportPDFButton() {
    return StreamBuilder<List<XFile>>(
      stream: _assetsController.imageStream,
      builder: (context, snapshot) {
        final _images = snapshot.data?.map((e) => e.toFile()).toList() ?? [];

        final bool _canExport = _images.isNotEmpty;
        print(_canExport);

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

class _PDFExportDialog extends StatefulWidget {
  @override
  __PDFExportDialogState createState() => __PDFExportDialogState();
}

class __PDFExportDialogState extends State<_PDFExportDialog> {
  PDFExportOptions _options = const PDFExportOptions();

  void _changeOptions(PDFExportOptions newOptions) {
    _options = _options.merge(other: newOptions);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Export PDF"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PDFExportDropDownListTile<PdfPageFormat>(
            title: "Paper Size",
            initialValue: PdfPageFormat.a4,
            options: const [
              DropdownMenuItem(
                child: Text("A3"),
                value: PdfPageFormat.a3,
              ),
              DropdownMenuItem(
                child: Text("A4"),
                value: PdfPageFormat.a4,
              ),
              DropdownMenuItem(
                child: Text("A5"),
                value: PdfPageFormat.a5,
              ),
              DropdownMenuItem(
                child: Text("Letter"),
                value: PdfPageFormat.letter,
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
          PDFExportDropDownListTile<PageOrientation>(
            title: "Layout",
            initialValue: PageOrientation.portrait,
            options: const [
              DropdownMenuItem(
                child: Text("Portrait"),
                value: PageOrientation.portrait,
              ),
              DropdownMenuItem(
                child: Text("Landscape"),
                value: PageOrientation.landscape,
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
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text(
            "Export",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.of(context).pop(_options);
          },
        ),
      ],
    );
  }
}

class PDFExportDropDownListTile<T> extends StatefulWidget {
  final String title;
  final List<DropdownMenuItem<T>> options;
  final T initialValue;
  final ValueChanged<T>? onChanged;

  const PDFExportDropDownListTile({
    Key? key,
    required this.title,
    required this.options,
    required this.initialValue,
    this.onChanged,
  }) : super(key: key);
  @override
  _PDFExportDropDownListTileState<T> createState() => _PDFExportDropDownListTileState<T>();
}

class _PDFExportDropDownListTileState<T> extends State<PDFExportDropDownListTile<T>> {
  T? _value;

  @override
  void initState() {
    _value = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.title, style: TextStyle(fontSize: 13)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(5),
          ),
          child: DropdownButton<T>(
            underline: Container(),
            isDense: true,
            value: _value,
            iconSize: 18,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            items: widget.options,
            onChanged: (value) {
              if (value == null) return;
              if (widget.onChanged != null) widget.onChanged!(value);
              setState(() => _value = value);
            },
          ),
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
