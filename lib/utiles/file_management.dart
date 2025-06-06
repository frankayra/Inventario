import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:file_picker/file_picker.dart';

// Copia el archivo <<fileName>> desde <<filePath>> hacia <<newSubPath>> dentro de la carpeta
//   que el almacenamiento del telefono dedica a la aplicacion, con el nuevo nombre <<newFileName>>.
Future<String> copyFileToDocuments({
  required String filePath,
  required String? fileName,
  List<String> newSubPathList = const [],
  String newFileName = "",
  bool fromAssets = false,
  bool override = false,
  bool userFilePick = false,
  List<String> allowedExtensions = const [],
  BuildContext? context,
}) async {
  String newSubPath = "${newSubPathList.join("/")}/";
  Directory newDirectory = Directory(
    "${(await getApplicationDocumentsDirectory()).path}/$newSubPath",
  );
  if (!await newDirectory.exists()) await newDirectory.create(recursive: true);

  final String newFilePath =
      "${newDirectory.path}${newFileName == "" ? fileName : newFileName}";
  File newFile = File(newFilePath);
  if (await newFile.exists() && !override) return newFilePath;

  // +++++++++++++++++++++++++++++++ //
  // +++++ Copiar desde assets +++++ //
  // +++++++++++++++++++++++++++++++ //
  if (fromAssets) {
    ByteData data = await rootBundle.load(filePath);
    final bytes = data.buffer.asUint8List();
    await newFile.writeAsBytes(bytes);

    // +++++++++++++++++++++++++++++++ //
    // ++++++ Seleccion manual +++++++ //
    // +++++++++++++++++++++++++++++++ //
  } else if (userFilePick) {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result != null) {
      File selectedFile = File(result.files.single.path!);
      await selectedFile.copy(newFilePath);
    } else {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se seleccionó ningún archivo')),
        );
      }
    }
    // ++++++++++++++++++++++++++++++++++++++++++ //
    // ++++++ Copiar desde el almac. int. +++++++ //
    // ++++++++++++++++++++++++++++++++++++++++++ //
  } else {
    File(filePath).copy(newFilePath);
  }

  return newFilePath;
}

Future<void> manageMapAndDlimitiationDirectories() async {
  Directory appDirectory = await getApplicationDocumentsDirectory();
  if (!await Directory(path.join(appDirectory.path, 'Mapas')).exists()) {}
  if (!await Directory(
    path.join(appDirectory.path, 'Delimitaciones'),
  ).exists()) {}
}

Future<String?> selectFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    return result.files.single.path;
  } else {
    return null;
  }
}
