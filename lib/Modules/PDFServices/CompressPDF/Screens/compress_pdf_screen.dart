import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:free_pdf_utilities/Modules/PDFServices/CompressPDF/pdf_compression_controller.dart';
import 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';
import 'package:free_pdf_utilities/Screens/root_screen.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CompressPDFScreen extends StatefulWidget {
  const CompressPDFScreen({Key? key}) : super(key: key);

  @override
  _CompressPDFScreenState createState() => _CompressPDFScreenState();
}

class _CompressPDFScreenState extends State<CompressPDFScreen> {
  late PDFCompressionController _pdfCompressionController;
  @override
  void initState() {
    _pdfCompressionController = PDFCompressionController();
    super.initState();
  }

  @override
  void dispose() {
    _pdfCompressionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CAppBar(
        title: "Compress PDF",
        leading: [
          IconButton(
            onPressed: () {
              // if (_assetsController.isEmptyDocument) return Navigator.pop(context);
              // showDialog(context: context, builder: (_) => _renderDismissAlertDialog());
              Navigator.pop(context);
            },
            splashRadius: 15,
            iconSize: 15,
            icon: BackButtonIcon(),
          ),
        ],
        actions: [
          IconButton(
            splashRadius: 15,
            onPressed: () async {
              final _file = await _pdfCompressionController.generateDoument(PDFCompressionExportOptions());
              print(filesize((await _file.readAsBytes()).length));
              var dateTime = DateTime.now();
              await _file.saveTo(join((await getApplicationDocumentsDirectory()).path,
                  "generated${dateTime.minute + dateTime.second}.pdf"));
              print("DONE");
            },
            icon: Icon(CupertinoIcons.tray_arrow_up_fill),
            iconSize: 18,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pdfCompressionController.pickFiles(),
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.doc_richtext,
                size: _size.width / 3.0,
              ),
              SizedBox(height: 30),
              Text("Document name"),
              Text(DateTime.now().toIso8601String()),
              Text("1.5MB")
            ],
          ),
        ),
      ),
    );
  }
}
