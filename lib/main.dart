import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para copiar archivos de assets
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart'; // Para obtener la carpeta interna
import 'package:mbtiles/mbtiles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MbTilesTileProvider _mbTilesProvider;
  String? _dbPath;

  @override
  void initState() {
    super.initState();
    _prepareMBTiles().then((path) async {
      final mbTiles = await MbTiles.create(
        mbtilesPath: path,
        metadata: MbTilesMetadata(name: "mapa de la Habana", format: "jpg"),
      ); // Carga el archivo MBTiles
      setState(() {
        _dbPath = path;
        _mbTilesProvider = MbTilesTileProvider(mbtiles: mbTiles);
      });
    });
  }

  Future<String> _prepareMBTiles() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/partedelahabana.mbtiles';

    // Copiar el archivo solo si no existe en almacenamiento interno
    if (!File(dbPath).existsSync()) {
      ByteData data = await rootBundle.load(
        'assets/tiles/partedelahabana.mbtiles',
      );
      List<int> bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes);
    }

    return dbPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa Offline con MBTiles")),
      body:
          _dbPath == null
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Esperar hasta que el archivo se copie
              : FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(37.7749, -122.4194),
                  initialZoom: 5,
                ),
                children: [
                  TileLayer(tileProvider: _mbTilesProvider, urlTemplate: ""),
                ],
              ),
    );
  }
}
