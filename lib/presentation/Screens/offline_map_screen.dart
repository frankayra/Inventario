import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import '../../utiles/copy_to_internal_disk.dart';

class OfflineMapScreen extends StatefulWidget {
  const OfflineMapScreen({super.key});

  @override
  _OfflineMapScreenState createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends State<OfflineMapScreen> {
  static late Future<MbTilesTileProvider> _tileProviderFuture;
  static bool _isTileProviderInitialized = false;

  @override
  void initState() {
    super.initState();
    // if (_isTileProviderInitialized) {
    //   return;
    // }
    _isTileProviderInitialized = true;
    _tileProviderFuture = _initializeTileProvider();
  }

  Future<MbTilesTileProvider> _initializeTileProvider() async {
    // Obtener el directorio de documentos donde se encuentra el archivo .mbtiles
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String mbtilesFilePath = '${documentsDir.path}/habana.mbtiles';
    // String mbtilesFilePath = '/data/user/0/com.example.flutter_application_1/files/habana.mbtiles';

    // Verificar si el archivo .mbtiles existe
    if (!File(mbtilesFilePath).existsSync()) {
      throw Exception(
        'El archivo mapa.mbtiles no se encontró en $mbtilesFilePath',
      );
    }

    // Crear y devolver el proveedor de tiles MBTiles
    return MbTilesTileProvider.fromPath(path: mbtilesFilePath);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MbTilesTileProvider>(
      future: _tileProviderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final tileProvider = snapshot.data!;
          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(23.14467, -82.35550),
                  initialZoom: 11.0,
                ),
                children: [TileLayer(tileProvider: tileProvider)],
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
