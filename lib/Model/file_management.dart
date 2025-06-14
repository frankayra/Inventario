import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++       ++++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++             +++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++    Archivos   ++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++             +++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++       ++++++++++++++++++++++++++++++ //

/// Copia el archivo &lt;fileName&gt; desde &lt;filePath&gt; hacia &lt;newSubPath&gt; dentro de la carpeta
///   que el almacenamiento del telefono dedica a la aplicacion, con el nuevo nombre &lt;newFileName&gt;.
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

Future<bool> initializeAppDirectories(List<String> appDirectoriesPaths) async {
  if (!await requestStoragePermission()) return false;
  for (var path in appDirectoriesPaths) {
    final subDirectory = Directory(path);
    if (!await subDirectory.exists()) {
      subDirectory.create(recursive: true);
      print("directorio creado: $subDirectory.path");
    }
  }
  return true;
}

Future<String?> selectFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    return result.files.single.path;
  } else {
    return null;
  }
}

Future<String?> selectDirectory() async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory != null) {
    return selectedDirectory;
  } else {
    return null;
  }
}

Future<String?> exportDBAsFile({required String exportPath}) async {
  File dbFile = File(path.join(await getDatabasesPath(), 'inventario.db'));
  if (await dbFile.exists()) {
    try {
      await dbFile.copy(path.join(exportPath, "inventario.db"));
      return exportPath;
    } catch (e) {
      return null;
    }
  }
  return null;
}

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++       ++++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++             +++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++      Mapa     ++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++             +++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++       ++++++++++++++++++++++++++++++ //
/// Devuelve un archivo que referencia al mapa. En caso de estar en los assets de la app,
/// copia el mapa al espacio privado de la app y devuelve un File apuntando hacia alli
Future<File?> getMapFile({required String filePath}) async {
  List<String> filePathSplitted = path.split(path.normalize(filePath));
  String fileName = filePathSplitted.last;
  String fileSource = filePathSplitted.firstWhere(
    (value) => value.trim() != "",
  );
  String mapDocumentsPath = path.join(
    (await getApplicationDocumentsDirectory()).path,
    fileName,
  );
  File mapFile = File(filePath);
  if (await mapFile.exists()) {
    return mapFile;
  } else if (fileSource == "assets") {
    mapFile = File(mapDocumentsPath);
    if (!await mapFile.exists()) {
      try {
        mapFile = File(
          await copyFileToDocuments(
            fileName: fileName,
            filePath: filePath,
            fromAssets: true,
            override: true,
          ),
        );
      } catch (e) {
        return null;
      }
    }
  }
  return mapFile;
}

String? pickMapFromMapsFolder(String mapsFolderPath) {
  final mapsDirectory = Directory(mapsFolderPath);
  if (!mapsDirectory.existsSync()) {
    // El directorio no existe
    return null;
  }
  final filesInDirectory = mapsDirectory.listSync(
    recursive: true,
    followLinks: false,
  );
  for (var file in filesInDirectory) {
    if (file is File && file.path.toLowerCase().endsWith('.mbtiles')) {
      return path.normalize(file.path);
    }
  }
  // No se encontró ningún archivo
  return null;
}

List<({String path, Color color})> getAllDelimitations(
  String delimitationsFolderPath,
) {
  final mapsDirectory = Directory(delimitationsFolderPath);
  if (!mapsDirectory.existsSync()) {
    // El directorio no existe
    return [];
  }
  final filesInDirectory = mapsDirectory.listSync(
    recursive: true,
    followLinks: false,
  );
  var colors = [Colors.black, Colors.blue, Colors.yellow];
  int colorIndex = 0;
  var result = <({String path, Color color})>[];
  for (var file in filesInDirectory) {
    if (file is File && file.path.toLowerCase().endsWith('.geojson')) {
      if (file.path.toLowerCase().endsWith("_predios.geojson")) {
        result.add((path: path.normalize(file.path), color: Colors.red));
      } else {
        result.add((
          path: path.normalize(file.path),
          color: colors[colorIndex++],
        ));
      }
    }
  }
  return result;
}

Future<String?> importMap(
  String mapPath, {
  required String newFolderPath,
}) async {
  File mapFile = File(mapPath);
  String newMapPath = path.join(newFolderPath, path.basename(mapPath));
  try {
    if (await mapFile.exists() &&
        mapFile.path.toLowerCase().endsWith('.mbtiles')) {
      await mapFile.rename(newMapPath);
      return newMapPath;
    }
  } catch (e) {
    try {
      // File newMapFile = File(newMapPath);
      // await newMapFile.writeAsBytes(await mapFile.readAsBytes());
      await mapFile.copy(newMapPath);
      await mapFile.delete();
      return newMapPath;
    } catch (e) {
      return null;
    }
  }
  return null;
}

Future<String?> importDelimitations(
  String delimitationPath, {
  required String newFolderPath,
}) async {
  File delimitationFile = File(delimitationPath);
  String newDelimitationPath = path.join(
    newFolderPath,
    path.basename(delimitationPath),
  );
  try {
    if (await delimitationFile.exists() &&
        delimitationFile.path.toLowerCase().endsWith('.geojson')) {
      await delimitationFile.rename(newDelimitationPath);
      return newDelimitationPath;
    }
  } catch (e) {
    try {
      // File newMapFile = File(newMapPath);
      // await newMapFile.writeAsBytes(await mapFile.readAsBytes());
      await delimitationFile.copy(newDelimitationPath);
      await delimitationFile.delete();
      return newDelimitationPath;
    } catch (e) {
      return null;
    }
  }
  return null;
}

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++       ++++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++             +++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++    Permisos   ++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++             +++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++       ++++++++++++++++++++++++++++++ //

Future<bool> requestStoragePermission() async {
  int sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
  PermissionStatus status = await _askForStoragePermision(
    sdkInt,
    justGet: true,
  );
  if (!status.isGranted) {
    if (status.isDenied) {
      status = await _askForStoragePermision(sdkInt);
    } else if (status.isPermanentlyDenied) {
      // Esto abre la configuración del sistema para conceder MANAGE_EXTERNAL_STORAGE
      bool settingsWereOppened = await openAppSettings();
      if (!settingsWereOppened) return false;
    }
  }
  return status.isGranted;
}

Future<PermissionStatus> _askForStoragePermision(
  int sdkVersion, {
  bool justGet = false,
}) async {
  if (sdkVersion < 30) {
    // Android 10-
    var permission = Permission.storage;
    return justGet ? await permission.status : await permission.request();
  } else if (sdkVersion >= 30) {
    // Android 11+
    var permission = Permission.manageExternalStorage;
    if (justGet) return await permission.status;
    var startTime = DateTime.now();
    var request = await permission.request();
    if (request != PermissionStatus.granted &&
        DateTime.now().difference(startTime) < Duration(milliseconds: 500)) {
      // Android 13+
      openAppSettings();
    }
  }
  return await Permission.manageExternalStorage.status;
}
