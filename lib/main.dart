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
import 'package:file_picker/file_picker.dart';

class AppContext {
  static const mapName = 'managua1.mbtiles';
  static const assetsMapPath = 'assets/tiles/$mapName';
  static late String destinationPath;
  static Future<void> initializeVariables() async {
    // Variables que se inicializan al inicio de la aplicacion
    // Se pueden usar en cualquier parte de la aplicacion
    destinationPath =
        '${(await getApplicationDocumentsDirectory()).path}/$mapName';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppContext.initializeVariables();

  await copyMbtilesToDocuments(AppContext.assetsMapPath, AppContext.mapName);

  // Verificar si el mapa esta en el lugar correcto
  if (!await File(AppContext.destinationPath).exists()) {
    throw Exception(
      'El archivo mapa.mbtiles no se encontró en ${AppContext.destinationPath}',
    );
  }

  runApp(MyScafold());
}

//
//
//
//

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
              Text(' Inventario'),
              ElevatedButton(
                onPressed: _selectFile,
                child: Icon(Icons.file_open),
              ),
            ],
          ),
        ),
        body:
            _selectedIndex == 0
                ? OfflineMapScreen(mbtilesFilePath: AppContext.destinationPath)
                : EdificacionForm(), // Reemplaza con tu otro widget
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
            BottomNavigationBarItem(icon: Icon(Icons.widgets), label: 'Otro'),
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

  Future<MbTilesTileProvider> _initializeTileProvider() async {
    final directory = await getApplicationDocumentsDirectory();
    return MbTilesTileProvider.fromPath(path: AppContext.destinationPath);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
