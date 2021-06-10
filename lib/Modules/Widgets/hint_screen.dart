import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

///Displays a screen hint with an `SVG` image and a hint `title`.
class ToolHintScreen extends StatelessWidget {
  final String title;

  ///`SVG` asset path.
  final String assetPath;
  final TextStyle? titleStyle;

  const ToolHintScreen({
    Key? key,
    required this.title,
    required this.assetPath,
    this.titleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          assetPath,
          height: MediaQuery.of(context).size.height / 2,
        ),
        SizedBox(height: 30),
        Text(title,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white70,
            ).merge(titleStyle)),
      ],
    );
  }
}
