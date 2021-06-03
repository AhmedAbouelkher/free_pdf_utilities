import 'package:flutter/material.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/Models/assets_controller.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';

class PDFImageItem extends StatefulWidget {
  final CxFile pdfFile;
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
                child: Image.file(widget.pdfFile.internal.toFile()),
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
                  SizedBox(
                    width: 140 / 2,
                    child: Divider(),
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
