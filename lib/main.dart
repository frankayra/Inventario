import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'utiles/file_management.dart';
import 'presentation/Screens/offline_map_screen.dart';
import 'presentation/Screens/form_screen.dart';
import 'presentation/Screens/form2_screen.dart';
import 'package:file_picker/file_picker.dart';

class AppContext {
  static late String mapName = "habana.mbtiles";
  static late String assetsMapPath = "assets/tiles/$mapName";
  static late String appDocumentsMapPath;
  static Future<void> initializeVariables() async {
    // Variables que se inicializan al inicio de la aplicacion
    // Se pueden usar en cualquier parte de la aplicacion
    appDocumentsMapPath =
        '${(await getApplicationDocumentsDirectory()).path}/$mapName';
  }

  static Future<void> updateVariables() async {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppContext.initializeVariables();

  final mapNewPath = await copyFileToDocuments(
    filePath: AppContext.assetsMapPath,
    fileName: AppContext.mapName,
    newSubPathList: ["Mapas"],
    fromAssets: true,
  );
  if (!File(mapNewPath).existsSync())
    throw Exception(
      "El archivo ${AppContext.mapName} no se encontró en la ruta $mapNewPath",
    );
  AppContext.appDocumentsMapPath = mapNewPath;
  runApp(MyScafold());
}

class MyScafold extends StatefulWidget {
  const MyScafold({super.key});

  @override
  State<MyScafold> createState() => _MyScafoldState();
}

class _MyScafoldState extends State<MyScafold> {
  late Future<MbTilesTileProvider> _tileProviderFuture;
  int _selectedIndex = 0;
  String? _map_path;
  File? _map_file;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.home_filled),
              Text(' Inventario '),
              ElevatedButton(
                onPressed: _selectFile,
                child: Icon(Icons.file_open),
              ),
            ],
          ),
        ),
        body:
            _selectedIndex == 0
                ? OfflineMapWidget(
                  /// ++++++++++++++++++++++++++++++++ ///
                  /// +++++++++ MAP SETTINGS +++++++++ ///
                  /// ++++++++++++++++++++++++++++++++ ///
                  mbtilesFilePath: AppContext.appDocumentsMapPath,
                  delimitationLayersDescriptions: [
                    (
                      path: 'assets/Delimitations/manzanas_habana.geojson',
                      color: Colors.red,
                    ),
                    (
                      path: 'assets/Delimitations/predios_habana.geojson',
                      color: Colors.green,
                    ),
                  ],

                  /// -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ ///
                )
                // : EdificacionForm(),
                : FormularioInspeccion(),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
            BottomNavigationBarItem(
              icon: Icon(Icons.widgets),
              label: 'Registro',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tileProviderFuture = _initializeTileProvider();
  }

  Future<MbTilesTileProvider> _initializeTileProvider() async =>
      MbTilesTileProvider.fromPath(path: AppContext.appDocumentsMapPath);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //
  //
  //
  //
  //
  //
  //
  //
  //

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _map_path = result.files.single.path;
        _map_file = File(_map_path!);
      });
      print('Ruta del archivo seleccionado: $_map_path');
      print('Archivo seleccionado: $_map_file');
      // Aquí puedes usar _map_path o _map_file para cargar el archivo.
    } else {
      // El usuario canceló la selección.
      print('Selección de archivo cancelada.');
    }
  }
}
