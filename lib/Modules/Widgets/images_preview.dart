import 'package:flutter/material.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/Models/assets_controller.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';

//TODO: Use custom change notifier controller instead of `PageController`.

///Shows an image preview which the user can see the provided images more clearly.
///
///Use static method `ImagesPreview.showOverlay()` to show the previewer as an overlay on the screen.
///Use static method `ImagesPreview.removeOverlay()` to remove the overlay.
///
class ImagesPreview extends StatefulWidget {
  ///The images which the user would interact with.
  final List<CxFile> images;

  ///The initial image index to be shown to the user.
  ///
  ///Defauts to `0`
  final int initialIndex;

  const ImagesPreview({
    Key? key,
    required this.images,
    this.initialIndex = 0,
  }) : super(key: key);

  //* Overlay Code
  static OverlayEntry? _overlayEntry;
  static bool _isOverlayMounted = false;
  static bool get isOverlayMounted => _isOverlayMounted;

  ///Inserts the `ImagesPreview` widget as an overlay.
  ///
  ///Note: `ImagesPreview.removeOverlay()` must be called to remove the inserted overlay.
  static OverlayEntry showOverlay(BuildContext context, {required ImagesPreview preview}) {
    _isOverlayMounted = true;
    _overlayEntry = OverlayEntry(builder: (context) => Positioned(child: preview));
    Overlay.of(context)!.insert(_overlayEntry!);
    return _overlayEntry!;
  }

  ///Removes the overlay.
  static void removeOverlay() {
    assert(_overlayEntry != null, "You should show the overlay first before removing it -_-");
    _overlayEntry!.remove();
    _overlayEntry = null;
    _isOverlayMounted = false;
  }

  @override
  _ImagesPreviewState createState() => _ImagesPreviewState();
}

class _ImagesPreviewState extends State<ImagesPreview> {
  late PageController _pageController;
  late ValueNotifier<int> _currentPage;

  @override
  void initState() {
    _pageController = PageController(
      initialPage: widget.initialIndex,
    );
    _currentPage = ValueNotifier(widget.initialIndex);

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return Material(
      color: Colors.black54,
      elevation: 0.0,
      child: Column(
        children: [
          SizedBox(height: kToolbarHeight + 20.0),
          Expanded(
            child: PageView.builder(
              physics: const ClampingScrollPhysics(),
              onPageChanged: (pageIndex) => _currentPage.value = pageIndex,
              controller: _pageController,
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                final _image = widget.images[index].internal.toFile();
                return InteractiveViewer(
                  child: Image.file(_image),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Container(
            color: Colors.grey[850],
            // height: _size.height * 0.09,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.1, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => ImagesPreview.removeOverlay(),
                          icon: Icon(Icons.close),
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: _currentPage,
                          builder: (context, value, _) {
                            final _image = widget.images[value];
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: 10,
                                maxWidth: _size.width * 0.4,
                              ),
                              child: Text(
                                _image.baseName ?? "-",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: _currentPage,
                    builder: (context, value, _) {
                      final _canGoPreviousPage = (value - 1) >= 0;

                      final _canGoNextPage = (value + 1) <= widget.images.length - 1;

                      return Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: !_canGoPreviousPage
                                  ? null
                                  : () => _pageController.previousPage(duration: kDuration, curve: Curves.ease),
                              icon: Icon(Icons.arrow_back_ios),
                            ),
                            IconButton(
                              onPressed: !_canGoNextPage
                                  ? null
                                  : () => _pageController.nextPage(duration: kDuration, curve: Curves.ease),
                              icon: Icon(Icons.arrow_forward_ios),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
