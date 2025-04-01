import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'utiles/copy_to_internal_disk.dart';
import 'presentation/Screens/offline_map_screen.dart';
import 'presentation/Screens/form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Directory documentsDir = await getApplicationDocumentsDirectory();
  final String destinationPath = '${documentsDir.path}/habana.mbtiles';
  await copyMbtilesToDocuments('assets/tiles/habana.mbtiles');

  // Verificar si ya existe para evitar copiarlo de nuevo
  if (!await File(destinationPath).exists()) {
    throw Exception(
      'El archivo mapa.mbtiles no se encontró en $destinationPath',
    );
  }

  runApp(MyApp());
}

//
//
//
//

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Inventario', home: MyScafold());
  }
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

  @override
  void initState() {
    super.initState();
    _tileProviderFuture = _initializeTileProvider();
  }

  Future<MbTilesTileProvider> _initializeTileProvider() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/habana.mbtiles';
    return MbTilesTileProvider.fromPath(path: path);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Icon(Icons.home_filled), Text(' Inventario')]),
      ),
      body:
          _selectedIndex == 0
              ? OfflineMapScreen()
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
    );
  }
}
