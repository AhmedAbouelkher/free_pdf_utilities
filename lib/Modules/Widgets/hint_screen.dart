import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/app_theme.dart';

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
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            color: themed(context, dark: Colors.white70, light: Colors.black54),
          ).merge(titleStyle),
        ),
      ],
    );
  }
}
