import 'dart:io';
import 'package:flutter/material.dart';

/// Switches between for example `AlertDialog` action button.
/// Defaults to `macOS` style -> [Primary Button] [Cancel Button]
///
/// Layout:-
///  - Windows/Linux : [Cancel Button] [Primary Button]
///  - macOS :         [Primary Button] [Cancel Button]
///
class PlatformItemsSwitcher extends StatelessWidget {
  ///Widget `Buttons` to switch
  final List<Widget> children;
  const PlatformItemsSwitcher({
    Key? key,
    required this.children,
  }) : super(key: key);

  ///Returns `SizedBox`.
  static Widget actionsSpace([double width = 8]) => SizedBox(width: width);

  @override
  Widget build(BuildContext context) {
    // assert(items.length > 3, "You must provider two widgets (with optional spacing) to switch between.");
    // Windows dialog buttons run a different direction then others
    TextDirection btnDirection = Platform.isWindows ? TextDirection.rtl : TextDirection.ltr;
    return Row(
      textDirection: btnDirection,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
