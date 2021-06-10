import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_grid/responsive_grid.dart';

import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';
import 'package:free_pdf_utilities/Modules/PDFServices/CompressPDF/Screens/compress_pdf_screen.dart';
import 'package:free_pdf_utilities/Modules/PDFServices/PNG_TO_PDF/Screens/images_to_PDF_screen.dart';
import 'package:free_pdf_utilities/Modules/Settings/Screens/Settings/settings_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  void _navigateToSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _renderAppBar(),
      body: Padding(
        padding: kMainPadding,
        child: ResponsiveGridList(
          desiredItemWidth: 120,
          minSpacing: 10,
          squareCells: true,
          children: [
            _ToolItem(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PNGtoPDFScreen())),
              icon: Icon(FontAwesomeIcons.fileImage),
              title: "Images to PDF",
            ),
            _ToolItem(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompressPDFScreen())),
              icon: Icon(FontAwesomeIcons.fileArchive),
              title: "Compress PDF",
            ),
          ],
        ),
      ),
    );
  }

  AppBar _renderAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Hero(
        tag: "CAppBar_title",
        child: Text(
          kAppName,
          style: TextStyle(fontSize: 15),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 10),
          child: IconButton(
            splashRadius: 15,
            onPressed: _navigateToSettings,
            icon: Icon(Icons.settings),
          ),
        ),
      ],
    );
  }
}

class _ToolItem extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Widget? icon;
  final TextStyle? titleStyle;

  const _ToolItem({
    Key? key,
    required this.title,
    this.onTap,
    this.icon,
    this.titleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _kBoxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8.0),
      gradient: LinearGradient(
        colors: [Colors.cyan, Colors.cyan[400]!],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    );
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: _kBoxDecoration,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                IconTheme.merge(
                  data: IconThemeData(
                    size: 40,
                  ),
                  child: icon!,
                ),
              SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle().merge(titleStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
