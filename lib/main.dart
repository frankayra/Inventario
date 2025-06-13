import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as path;

import 'package:inventario/Model/file_management.dart';
import 'presentation/Screens/offline_map_screen.dart';
import 'presentation/Screens/form_screen.dart';
import 'package:inventario/Model/db_general_management.dart' as db;
import 'package:inventario/Model/db_debug.dart';
import 'package:inventario/Model/tools_selection.dart';
import 'package:inventario/presentation/Screens/Form sections/Encuestador.dart';

class AppContext {
  String customRootPath = "/storage/emulated/0/CADIC";
  String customMapsPath = "/storage/emulated/0/CADIC/Maps";
  String customConfigPath = "/storage/emulated/0/CADIC/config";
  String customDBExportPath = "/storage/emulated/0/CADIC/Exportado";
  String customDelimitationsPath = "/storage/emulated/0/CADIC/Delimitaciones";
  String _mapName;
  late String assetsMapPath;
  late String customMapPath;
  bool storagePermissionGranted = false;
  bool nombreEncuestadorGranted = false;

  AppContext({required String mapName}) : _mapName = mapName {
    customRootPath = path.normalize(customRootPath);
    customMapsPath = path.normalize(customMapsPath);
    customConfigPath = path.normalize(customConfigPath);
    customDBExportPath = path.normalize(customDBExportPath);
    customDelimitationsPath = path.normalize(customDelimitationsPath);
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
    appContext.customMapsPath,
    appContext.customDelimitationsPath,
    appContext.customDBExportPath,
  ]);

  if (foldersCreated) {
    appContext.storagePermissionGranted = true;
  }
  if ((await db.getEncuestador()) != null) {
    appContext.nombreEncuestadorGranted = true;
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
  List<int> prediosListos = [];
  static late Widget offlineMap;

  @override
  void initState() {
    super.initState();
    String? mapPath;
    if (!File(widget.appContext.customMapPath).existsSync()) {
      mapPath = pickMapFromMapsFolder(widget.appContext.customMapsPath);
      if (mapPath != null) {
        widget.appContext.mapName = path.split(mapPath).last;
      } else {
        // widget.appContext.mapName = "managua18.mbtiles";
        widget.appContext.customMapPath = widget.appContext.assetsMapPath;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.appContext.nombreEncuestadorGranted) {
      return Scaffold(
        body: EncuestadorForm(onSaved: nombreEncuestadorIntroduced),
      );
    } else if (widget.appContext.storagePermissionGranted) {
      if (DateTime.now().isAfter(DateTime(2025, 07, 18))) {
        throw Error();
      }
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
                      importMapsPath: widget.appContext.customMapsPath,
                      importDelimitationsPath:
                          widget.appContext.customDelimitationsPath,
                      clearDBFunction: clearDBFunction,
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
                        widget.appContext.customMapsPath,
                        widget.appContext.customDelimitationsPath,
                        widget.appContext.customDBExportPath,
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
        return OfflineMapWidget(
          /// ++++++++++++++++++++++++++++++++ ///
          /// +++++++++ MAP SETTINGS +++++++++ ///
          /// ++++++++++++++++++++++++++++++++ ///
          mbtilesFilePath: widget.appContext.customMapPath,

          prediosListos: prediosListos,
          delimitationLayers: getAllDelimitations(
            widget.appContext.customDelimitationsPath,
          ),
          onLocationTap: predioTapped,

          /// -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ ///
        );
      case 1:
        return FormularioInspeccion(
          idPredio: _tappedLocation,
          predioListoCallbackFunction: predioListoCallbackFunction,
        );
      default:
        return Container();
    }
  }

  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++++++++++       ++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++++             +++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++++++   Callbacks   ++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++++             +++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++++++++++       ++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void predioTapped(int tappedLocation) {
    setState(() {
      _tappedLocation = tappedLocation;
      _selectedIndex = 1;
    });
  }

  void nombreEncuestadorIntroduced(String nombreEncuestador) async {
    setState(() {
      widget.appContext.nombreEncuestadorGranted = true;
    });
  }

  void mapPointTapCallbackFunction(LatLng point) {}
  void predioListoCallbackFunction(int idPredio) {
    prediosListos.add(idPredio);
    setState(() {
      _selectedIndex = 0;
    });
  }

  void clearDBFunction() {
    db.clearDB();
  }
}
