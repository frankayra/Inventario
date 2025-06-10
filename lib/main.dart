import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'presentation/Screens/Form sections/Widgets/utiles/file_management.dart';
import 'presentation/Screens/offline_map_screen.dart';
// import 'presentation/Screens/form_screen.dart';
// import 'presentation/Screens/form2_screen.dart';
import 'presentation/Screens/form3_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:inventario/presentation/Screens/Form%20sections/Widgets/utiles/db_general_management.dart'
    as db;
import 'package:inventario/presentation/Screens/Form%20sections/Widgets/utiles/db_debug.dart';
import 'package:inventario/presentation/Screens/Form%20sections/Widgets/utiles/tools_selection.dart';

class AppContext {
  static String mapName = "managua18.mbtiles";
  static String assetsMapPath = "assets/tiles/$mapName";
  static late String appDocumentsMapPath;
  static Future<void> initializeVariables() async {
    appDocumentsMapPath =
        '${(await getApplicationDocumentsDirectory()).path}/$mapName';
  }
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
  runApp(
    MaterialApp(
      title: 'Inventario',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyScafold(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyScafold extends StatefulWidget {
  const MyScafold({super.key});

  @override
  State<MyScafold> createState() => _MyScafoldState();
}

class _MyScafoldState extends State<MyScafold> {
  late Future<MbTilesTileProvider> _tileProviderFuture;
  int _selectedIndex = 0;
  int _tappedLocation = -1;
  String? _map_path;
  File? _map_file;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(children: [Icon(Icons.home_filled), Text(' Inventario ')]),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => ToolsSelection()),
              // );
              showDialog(
                context: context,
                barrierDismissible: true,
                barrierColor: Colors.black.withValues(
                  alpha: 0.2,
                ), // fondo semitransparente
                builder: (context) {
                  return ToolsSelection();
                },
              );
            },
            child: Icon(Icons.file_open),
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => DBDebugDialog(),
              );
            },
          ),
        ],
      ),
      body:
          _selectedIndex == 0
              ? OfflineMapWidget(
                /// ++++++++++++++++++++++++++++++++ ///
                /// +++++++++ MAP SETTINGS +++++++++ ///
                /// ++++++++++++++++++++++++++++++++ ///
                mbtilesFilePath: AppContext.appDocumentsMapPath,
                delimitationLayers: [
                  (
                    path: 'assets/Delimitations/manzanas_managua.geojson',
                    color: Colors.green,
                  ),
                  (
                    path: 'assets/Delimitations/predios_managua.geojson',
                    color: Colors.black,
                  ),
                  // (
                  //   path: 'assets/Delimitations/managuaPredio.geojson',
                  //   color: Colors.black,
                  // ),
                ],
                onLocationTap: (int tappedLocation) {
                  setState(() {
                    _tappedLocation = tappedLocation;
                    _selectedIndex = 1;
                  });
                },

                /// -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ ///
              )
              // : EdificacionForm(),
              : FormularioInspeccion(idPredio: _tappedLocation),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.widgets), label: 'Registro'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
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

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++       ++++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++             +++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++   Callbacks   ++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++             +++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++       ++++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
void mapPointTapCallbackFunction(LatLng point) {}
