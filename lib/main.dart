import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:latlong2/latlong.dart';

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
  late MbTilesTileProvider _mbTilesProvider;

  @override
  void initState() {
    super.initState();
    _mbTilesProvider = MbTilesTileProvider.fromPath(
      path: 'assets/tiles/tiles.mbtiles',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa Offline con MBTiles")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
            37.7749,
            -122.4194,
          ), // Coordenadas de ejemplo (San Francisco)
          initialZoom: 5,
        ),
        children: [
          TileLayer(
            tileProvider: _mbTilesProvider,
            urlTemplate: "", // Se deja vacío ya que usa MBTiles
          ),
        ],
      ),
    );
  }
}
