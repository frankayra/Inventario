import 'dart:math';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:inventario/presentation/Screens/Form%20sections/Widgets/dialogs.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'presentation/Screens/Form sections/Widgets/utiles/file_management.dart';
import 'presentation/Screens/offline_map_screen.dart';
import 'presentation/Screens/form3_screen.dart';
import 'package:inventario/presentation/Screens/Form%20sections/Widgets/utiles/db_general_management.dart'
    as db;
import 'package:inventario/presentation/Screens/Form%20sections/Widgets/utiles/db_debug.dart';
import 'package:inventario/presentation/Screens/Form%20sections/Widgets/utiles/tools_selection.dart';

class AppContext {
  final String customRootPath = "/storage/emulated/0/CADIC";
  final String customMapsPath = "/storage/emulated/0/CADIC/Maps";
  final String customConfigPath = "/storage/emulated/0/CADIC/config";
  final String customDBExportPath = "/storage/emulated/0/CADIC/Exportado";
  final String customDelimitationsPath =
      "/storage/emulated/0/CADIC/Delimitaciones";
  String _mapName;
  late String assetsMapPath;
  late String customMapPath;
  bool storagePermissionGranted = false;

  AppContext({required String mapName}) : _mapName = mapName {
    assetsMapPath = "assets/tiles/$mapName";
    customMapPath = path.join(customMapsPath, _mapName);
  }
  set mapName(String newMapName) {
    _mapName = newMapName;
    assetsMapPath = "assets/tiles/$_mapName";
    customMapPath = path.join(customMapsPath, _mapName);
  }

  String get mapName => _mapName;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var appContext = AppContext(mapName: "managua18.mbtiles");
  final foldersCreated = await initializeAppDirectories([
    appContext.customMapPath,
    appContext.customDelimitationsPath,
    appContext.customDBExportPath,
  ]);

  if (foldersCreated) {
    appContext.storagePermissionGranted = true;
  }
  runApp(
    MaterialApp(
      title: 'Inventario',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyScafold(appContext: appContext),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyScafold extends StatefulWidget {
  final AppContext appContext;
  const MyScafold({super.key, required this.appContext});

  @override
  State<MyScafold> createState() => _MyScafoldState();
}

class _MyScafoldState extends State<MyScafold> {
  int _selectedIndex = 0;
  int _tappedLocation = -1;
  late Widget offlineMap;

  @override
  void initState() {
    super.initState();
    offlineMap = OfflineMapWidget(
      /// ++++++++++++++++++++++++++++++++ ///
      /// +++++++++ MAP SETTINGS +++++++++ ///
      /// ++++++++++++++++++++++++++++++++ ///
      mbtilesFilePath: widget.appContext.assetsMapPath,

      delimitationLayers: [
        (
          path: 'assets/Delimitations/manzanas_managua.geojson',
          color: Colors.green,
        ),
        (
          path: 'assets/Delimitations/predios_managua.geojson',
          color: Colors.black,
        ),
      ],
      onLocationTap: (int tappedLocation) {
        setState(() {
          _tappedLocation = tappedLocation;
          _selectedIndex = 1;
        });
      },

      /// -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ ///
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.appContext.storagePermissionGranted) {
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
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierColor: Colors.black.withValues(
                    alpha: 0.2,
                  ), // fondo semitransparente
                  builder: (context) {
                    return ToolsSelection(
                      exportPath: widget.appContext.customDBExportPath,
                    );
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
        body: buildScaffoldBody(),
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
      );
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Se necesita acceso al almacenamiento del dispositivo"),
              SizedBox(height: 50),
              ElevatedButton.icon(
                onPressed: () async {
                  widget.appContext.storagePermissionGranted =
                      await initializeAppDirectories([
                        widget.appContext.customMapPath,
                        widget.appContext.customDelimitationsPath,
                      ]);
                  setState(() {});
                },
                icon: Icon(Icons.file_copy),
                label: Text("Dar acceso"),
              ),
            ],
          ),
        ),
      );
    }
  }

  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++++++++++       ++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++++             +++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++++++     Utiles    ++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++++             +++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++++++++++       ++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  Widget buildScaffoldBody() {
    switch (_selectedIndex) {
      case 0:
        return offlineMap;
      case 1:
        return FormularioInspeccion(idPredio: _tappedLocation);
      default:
        return Container();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++       ++++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++             +++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++   Callbacks   ++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++             +++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++       ++++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
void mapPointTapCallbackFunction(LatLng point) {}
