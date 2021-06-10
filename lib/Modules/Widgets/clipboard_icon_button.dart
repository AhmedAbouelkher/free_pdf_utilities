import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///Helps to create quick clipboard button view.
class ClipboardIconButton extends StatefulWidget {
  ///The text to be saved in device Clipboard
  final String text;
  const ClipboardIconButton({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  _ClipboardIconButtonState createState() => _ClipboardIconButtonState();
}

class _ClipboardIconButtonState extends State<ClipboardIconButton> {
  bool _isChecked = false;

  void _switchState() {
    setState(() => _isChecked = !_isChecked);
  }

  void _clipboardPressed() async {
    _switchState();
    await Clipboard.setData(ClipboardData(text: widget.text));
    await Future.delayed(Duration(milliseconds: 1500));
    _switchState();
  }

  @override
  Widget build(BuildContext context) {
    Widget _replaced = IgnorePointer(
      child: IconButton(
        key: ValueKey(0),
        onPressed: () => null,
        splashRadius: 15,
        iconSize: 20,
        icon: Icon(CupertinoIcons.checkmark),
        color: Color(0xff39d313),
      ),
    );
    // return _replaced;
    Widget _main = IconButton(
      key: ValueKey(-1),
      onPressed: _clipboardPressed,
      splashRadius: 15,
      iconSize: 20,
      icon: Icon(CupertinoIcons.doc_on_clipboard),
    );
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      switchInCurve: Curves.decelerate,
      switchOutCurve: Curves.easeIn,
      child: !_isChecked ? _main : _replaced,
    );
  }
}
