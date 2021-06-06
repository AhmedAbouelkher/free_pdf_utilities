import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> showCustonSnackBar({
  required String message,
  required BuildContext context,
  Widget? icon,
  Duration? duration,
}) async {
  final _c = ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: duration ?? const Duration(milliseconds: 4000),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      content: Row(
        children: [
          if (icon != null) icon,
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  await _c.closed;
  return;
}

Future<void> showErrorBar({
  required String message,
  required BuildContext context,
}) async {
  return showCustonSnackBar(
    context: context,
    message: message,
    icon: Icon(
      CupertinoIcons.exclamationmark_circle,
      color: Colors.red,
      size: 35,
    ),
  );
}

Future<void> showSuccessBar({
  required String message,
  required BuildContext context,
}) async {
  return showCustonSnackBar(
    context: context,
    message: message,
    icon: Icon(
      CupertinoIcons.check_mark_circled_solid,
      color: Colors.green,
      size: 33,
    ),
  );
}
