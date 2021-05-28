import 'package:flutter/material.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';
import 'package:free_pdf_utilities/Modules/PDFServices/PNG_TO_PDF/Screens/PNG_to_PDF_screen.dart'
    hide ResponsiveGridList;
import 'package:free_pdf_utilities/Modules/Settings/Screens/settings_screen.dart';
import 'package:responsive_grid/responsive_grid.dart';

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
        child: SafeArea(
          child: ResponsiveGridList(
            desiredItemWidth: 100,
            minSpacing: 10,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PNGtoPDFScreen()));
                },
                child: Container(
                  height: 100,
                  alignment: Alignment(0, 0),
                  color: Colors.cyan,
                  child: Text("PNG TO PDF"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  AppBar _renderAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        kAppName,
        style: TextStyle(fontSize: 15),
      ),
      actions: [
        IconButton(
          splashRadius: 15,
          onPressed: _navigateToSettings,
          icon: Icon(Icons.settings),
        ),
      ],
    );
  }
}

class CAppBar extends StatelessWidget with PreferredSizeWidget {
  final List<Widget>? actions;
  final List<Widget>? leading;
  final String? title;
  const CAppBar({
    Key? key,
    this.actions,
    this.leading,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              title: Hero(
                tag: "CAppBar_title",
                child: Text(
                  title ?? "",
                  style: TextStyle(fontSize: 15),
                ),
              ),
              actions: actions,
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: leading ?? [BackButton()],
              ),
            ),
          ),
        ),
        Divider(height: 1),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
