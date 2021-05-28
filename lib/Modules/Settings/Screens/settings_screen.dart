import 'package:flutter/material.dart';
import 'package:free_pdf_utilities/Screens/root_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAppBar(
        leading: [],
        actions: [
          IconButton(
            splashRadius: 15,
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
        title: "Settings",
      ),
    );
  }
}
