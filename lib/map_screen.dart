// map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'map_service.dart';
import 'geojson_service.dart';
import 'zoom_manager.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  late Future<void> _mapDataFuture;

  @override
  void initState() {
    super.initState();
    _mapDataFuture = MapService().loadOfflineTiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa Offline")),
      body: FutureBuilder(
        future: _mapDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialZoom: 5,
              initialCenter: LatLng(37.7749, -122.4194),
              onTap: (tapPosition, point) {
                ZoomManager().handleZoomSelection(_mapController, point);
              },
            ),
            children: [
              TileLayer(
                tileProvider: MapService().getTileProvider(),
                urlTemplate: "",
              ),
              PolygonLayer(polygons: GeoJsonService().getPolygons()),
            ],
          );
        },
      ),
    );

    @override
    Widget build(BuildContext context) {
      // TODO: implement build
      throw UnimplementedError();
    }
  }
}
