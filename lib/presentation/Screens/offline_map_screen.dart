import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:inventario/presentation/Screens/mapa_debug.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import '../../utiles/file_management.dart';
import 'Map layers/terrains_limits_layer.dart';
import 'package:file_picker/file_picker.dart';

class OfflineMapWidget extends StatefulWidget {
  final String mbtilesFilePath;
  const OfflineMapWidget({required this.mbtilesFilePath, super.key});

  @override
  _OfflineMapWidgetState createState() =>
      _OfflineMapWidgetState(mbtilesFilePath: mbtilesFilePath);
}

class _OfflineMapWidgetState extends State<OfflineMapWidget> {
  final String mbtilesFilePath;
  static late Future<MbTilesTileProvider> _tileProviderFuture;
  static bool _isTileProviderInitialized = false;

  _OfflineMapWidgetState({required this.mbtilesFilePath});

  @override
  void initState() {
    super.initState();
    // if (_isTileProviderInitialized) {
    //   return;
    // }
    _isTileProviderInitialized = true;
    _tileProviderFuture = _initializeTileProvider();
  }

  // Future<MbTiles> _getMbTiles() async {
  //   if (!File(mbtilesFilePath).existsSync()) {
  //     throw Exception(
  //       'El archivo mapa.mbtiles no se encontró en $mbtilesFilePath',
  //     );
  //   }
  //   return MbTiles(mbtilesPath: mbtilesFilePath);
  // }

  Future<MbTilesTileProvider> _initializeTileProvider() async {
    // Obtener el directorio de documentos donde se encuentra el archivo .mbtiles
    // Directory documentsDir = await getApplicationDocumentsDirectory();
    // String mbtilesFilePath = '${documentsDir.path}/Map.mbtiles';
    // String mbtilesFilePath = '/data/user/0/com.example.flutter_application_1/files/habana.mbtiles';

    if (!File(mbtilesFilePath).existsSync()) {
      throw Exception(
        'El archivo mapa.mbtiles no se encontró en $mbtilesFilePath',
      );
    }

    return MbTilesTileProvider.fromPath(path: mbtilesFilePath);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MbTilesTileProvider>(
      future: _tileProviderFuture,
      // return FutureBuilder<MbTiles>(
      //   future: _getMbTiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final tileProvider = snapshot.data!;
          // final _mbtiles = snapshot.data!;
          // return getDebugMap(_mbtiles);
          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  // initialCenter: LatLng(23.14467, -82.35550), // Habana
                  initialCenter: LatLng(
                    23.17053428523392,
                    -82.27196563176855,
                  ), // Alamar
                  // initialCenter: LatLng(
                  //   12.145643078921182,
                  //   -86.26495747803298,
                  // ), // Managua
                  // initialCenter: LatLng(
                  //   -85.170815,
                  //   12.864564999999999,
                  // ), // Centro de Nicaragua

                  // initialCenter: LatLng(
                  //   43.66404747551534,
                  //   -79.3884040582291,
                  // ), // Toronto
                  // initialCenter: LatLng(
                  //   36.1555182044328,
                  //   -115.13386501485957,
                  // ), // California
                  initialZoom: 16.0,
                  maxZoom: 16.0,
                  minZoom: 10.0,
                  onTap: (TapPosition details, LatLng point) {
                    setState(() {
                      print(
                        'Coordenadas del clic: ${point.latitude}, ${point.longitude}',
                      );
                      // Aquí se puede realizar otras acciones con las coordenadas del clic
                    });
                  },
                ),
                children: [
                  TileLayer(tileProvider: tileProvider),
                  DelimitationsLayer(
                    geoJsonAssetPath:
                        'assets/Delimitations/manzanas_habana.geojson',
                    borderColor: Colors.green,
                  ),
                  DelimitationsLayer(
                    geoJsonAssetPath:
                        'assets/Delimitations/predios_habana.geojson',
                    borderColor: Colors.red,
                  ),
                ],
              ),
              Positioned(
                bottom: 16.0,
                right: 16.0,
                child: FloatingActionButton(
                  onPressed: () {
                    // Implementa la lógica para ir a la ubicación actual aquí
                  },
                  child: Icon(Icons.my_location),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _tileProviderFuture.then((tileProvider) => tileProvider.dispose());
    super.dispose();
  }
}
