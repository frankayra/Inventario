import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'Form sections/Widgets/utiles/file_management.dart';
import 'Map layers/terrains_limits_layer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';

const ALAMAR = LatLng(23.17053428523392, -82.27196563176855); // Alamar
const HABANA = LatLng(23.14467, -82.35550); // Habana
const MANAGUA = LatLng(12.145643078921182, -86.26495747803298); // Managua
const MANAGUA2 = LatLng(12.149240047336635, -86.25278121320335); // Managua
const NICARAGUA = LatLng(-85.170815, 12.864564999999999); // Centro de Nicaragua
const TORONTO = LatLng(43.66404747551534, -79.3884040582291); // Toronto
const CALIFORNIA = LatLng(36.1555182044328, -115.13386501485957); // California

class OfflineMapWidget extends StatefulWidget {
  final String mbtilesFilePath;
  List<({String path, Color color})>? delimitationLayers;
  void Function(int tappedLocation)? onLocationTap;
  OfflineMapWidget({
    required this.mbtilesFilePath,
    this.delimitationLayers,
    this.onLocationTap,
    super.key,
  });

  @override
  _OfflineMapWidgetState createState() =>
      _OfflineMapWidgetState(mbtilesFilePath: mbtilesFilePath);
}

class _OfflineMapWidgetState extends State<OfflineMapWidget> {
  final MapController _mapController = MapController();
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
    _tileProviderFuture = _initializeTileProvider(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MbTilesTileProvider>(
      future: _tileProviderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar el mapa: ${snapshot.error}'),
          );
        } else {
          final tileProvider = snapshot.data!;
          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: MANAGUA2,
                  initialZoom: 16.0,
                  maxZoom: 20.0,
                  minZoom: 0.0,
                  // onTap: (TapPosition details, LatLng point) {
                  //   setState(() {
                  //     // Aquí se puede realizar otras acciones con las coordenadas del clic
                  //   });
                  // },
                ),
                children: [
                  TileLayer(
                    tileProvider: tileProvider,
                    // tileProvider: AssetTileProvider(),
                    // urlTemplate: 'assets/tiles/managua/{z}/{x}/{y}.png',
                  ),
                  ...(widget.delimitationLayers != null
                      ? widget.delimitationLayers!
                          .map(
                            (layerDescription) => DelimitationsLayer(
                              geoJsonPath: layerDescription.path,
                              borderColor: layerDescription.color,
                              loadFromAssets: true,
                              onLocationTap: widget.onLocationTap,
                            ),
                          )
                          .toList()
                      : []),
                ],
              ),
              Positioned(
                bottom: 16.0,
                right: 16.0,
                child: FloatingActionButton(
                  onPressed: () async {
                    ///
                    ///
                    ///
                    ///
                    ///
                    Position? currentPosition = await _determinePosition();
                    if (currentPosition == null) return;
                    LatLng currentCoords = LatLng(
                      currentPosition.latitude,
                      currentPosition.longitude,
                    );
                    _mapController.move(currentCoords, 18.0);
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

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++      +++++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++          +++++++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++   Utiles   ++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++          +++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++      +++++++++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

  Future<MbTilesTileProvider> _initializeTileProvider(
    BuildContext context,
  ) async {
    if (!await File(mbtilesFilePath).exists()) {
      throw Exception(
        'El archivo mapa.mbtiles no se encontró en $mbtilesFilePath',
      );
    }

    try {
      final result = MbTilesTileProvider.fromPath(path: mbtilesFilePath);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ Mapa cargado correctamente!")));
      return result;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ No fue posible cargar el mapa")),
      );
      throw Future.error("❌ No fue posible cargar el mapa");
    }
  }

  @override
  void dispose() {
    _tileProviderFuture.then((tileProvider) => tileProvider.dispose());
    super.dispose();
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    return await Geolocator.getCurrentPosition();
  }
}
