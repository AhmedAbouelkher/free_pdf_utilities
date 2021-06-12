import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
    // ignore: non_constant_identifier_names
    final _8pxBorderRadius = BorderRadius.circular(5.0);
    return Material(
      elevation: 0.0,
      color: _isHoverActive ? Colors.white10 : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: _8pxBorderRadius,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.zoomIn,
        onHover: (value) {
          // print(value);
        },
        child: InkWell(
          hoverColor: Colors.transparent,
          onTap: widget.onTap ?? () {},
          onLongPress: widget.onLongPress,
          onHover: (value) {
            value ? _onHoverStart() : _onHoverEnd();
            setState(() => _isHoverActive = value);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: (210 / 282),
                    child: Container(
                      decoration: BoxDecoration(
                        // color: _isHoverActive ? Colors.black : Colors.white,
                        color: Colors.white,
                        borderRadius: _8pxBorderRadius,
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.file(widget.pdfFile.internal.toFile()),
                          ),
                          Positioned.fill(
                            child: AnimatedOpacity(
                              // opacity: 1.0,
                              opacity: _isHoverActive ? 1.0 : 0.0,
                              duration: kDuration,
                              child: Visibility(
                                // visible: true,
                                visible: _isHoverActive,
                                maintainAnimation: true,
                                maintainState: true,
                                child: AnimatedContainer(
                                  duration: kDuration,
                                  color: Colors.black26,
                                  child: _renderHoverContents(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ClippedDottedText(
                  Text(
                    widget.pdfFile.name ?? "-",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10),
                  ),
                  maxLength: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderHoverContents() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 12.0, 5.0, 20),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          // alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(99.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: widget.onPreview,
                icon: Icon(CupertinoIcons.eye),
                splashRadius: 15,
                iconSize: 18,
              ),
              IconButton(
                onPressed: widget.onRemove,
                icon: Icon(CupertinoIcons.trash),
                splashRadius: 15,
                iconSize: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///Get clipped text if the input length excedes `maxLength`
class ClippedDottedText extends StatelessWidget {
  ///The `Text()` widget.
  final Text text;

  ///Determins clipping or not.
  ///
  ///defaults to `true`
  final bool clip;

  ///The displayed text maximum length.
  ///
  ///defaults to `double.infinity`
  final int? maxLength;

  const ClippedDottedText(
    this.text, {
    Key? key,
    this.maxLength,
    this.clip = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _clipped = clip && text.data!.length >= (maxLength ?? double.infinity);
    if (_clipped) {
      final substring = text.data!.substring(0, maxLength);
      return Text(
        substring + "...",
        textAlign: text.textAlign,
        textDirection: text.textDirection,
        softWrap: text.softWrap,
        style: text.style,
        locale: text.locale,
        overflow: text.overflow,
      );
    }
    return text;
  }
}
