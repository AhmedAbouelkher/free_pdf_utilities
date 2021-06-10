import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const kAppName = "Free PDF Utilities";
const kAppRepo = "https://github.com/AhmedAbouelkher/free_pdf_utilities";
const EdgeInsetsGeometry kMainPadding = const EdgeInsets.all(20.0);
const Duration kDuration = const Duration(milliseconds: 200);
const kPythonDownload = "https://www.python.org/downloads/";
const kGhostScriptDownload = "https://www.ghostscript.com/download/gsdnld.html";

Future<Directory> appDocumentsDirectory() async {
  final _path = await getApplicationDocumentsDirectory();
  return Directory(join(_path.path, kAppName));
}

class Scripts {
  static String _scriptsDirPath = "https://raw.githubusercontent.com/AhmedAbouelkher/free_pdf_utilities/master/scripts";
  static Uri pythonCompression = Uri.parse(join(_scriptsDirPath, "pdf_compressor.py"));
}

///Credits:
/// - SVGs: [unDraw.co](https://undraw.co/)
class Assets {
  static const _assetsPath = "assets/";

  static const chooseSVG = _assetsPath + "undraw_Choose_bwbs.svg";
  static const convertSVG = _assetsPath + "undraw_convert_2gjv.svg";
  static const fileBundleSVG = _assetsPath + "undraw_File_bundle_xl7g.svg";
  static const wellDoneSVG = _assetsPath + "undraw_well_done_i2wr.svg";
  static const attachedFileSVG = _assetsPath + "undraw_attached_file_n4wm.svg";
  static const myFilesSVG = _assetsPath + "undraw_my_files_swob.svg";
  static const addFilesSVG = _assetsPath + "undraw_Add_files_re_v09g.svg";
}
