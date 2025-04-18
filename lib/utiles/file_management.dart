import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<String> copyMbtilesToDocuments(String path, String mapName) async {
  final Directory documentsDir = await getApplicationDocumentsDirectory();
  final String destinationPath = '${documentsDir.path}/$mapName';

  // Verificar si ya existe para evitar copiarlo de nuevo
  if (await File(destinationPath).exists()) {
    return destinationPath;
  }

  // Leer el archivo desde los assets
  final ByteData data = await rootBundle.load(path);
  final List<int> bytes = data.buffer.asUint8List();

  // Escribirlo en el almacenamiento interno
  await File(destinationPath).writeAsBytes(bytes);

  return destinationPath;
}
