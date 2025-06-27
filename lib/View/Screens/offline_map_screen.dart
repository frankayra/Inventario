import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as path;
import 'package:inventario/Model/file_management.dart';
import 'package:inventario/View/Screens/Map%20utilities/find_map_centroid.dart';
import 'Map utilities/terrains_limits_layer.dart';

const ALAMAR = LatLng(23.17053428523392, -82.27196563176855); // Alamar
const HABANA = LatLng(23.14467, -82.35550); // Habana
const MANAGUA = LatLng(12.145643078921182, -86.26495747803298); // Managua
const MANAGUA2 = LatLng(12.149240047336635, -86.25278121320335); // Managua
const NICARAGUA = LatLng(-85.170815, 12.864564999999999); // Centro de Nicaragua
const TORONTO = LatLng(43.66404747551534, -79.3884040582291); // Toronto
const CALIFORNIA = LatLng(36.1555182044328, -115.13386501485957); // California

class OfflineMapWidget extends StatefulWidget {
  static String? lastLoadedMapPath;
  static bool newMapLoaded = true;
  static LatLng? newMapCoords;
  final String mbtilesFilePath;
  List<({String path, Color color})>? delimitationLayers;
  List<int> prediosListos;
  void Function(int tappedLocation)? onLocationTap;
  bool loadFromAssets;
  OfflineMapWidget({
    required this.mbtilesFilePath,
    required this.prediosListos,
    this.delimitationLayers,
    this.onLocationTap,
    this.loadFromAssets = false,
    super.key,
  }) {
    if (lastLoadedMapPath != mbtilesFilePath) {
      lastLoadedMapPath = mbtilesFilePath;
      newMapLoaded = true;
    }
  }

  @override
  _OfflineMapWidgetState createState() =>
      _OfflineMapWidgetState(mbtilesFilePath: mbtilesFilePath);
}

class _OfflineMapWidgetState extends State<OfflineMapWidget>
    with AutomaticKeepAliveClientMixin {
  final MapController _mapController = MapController();
  String mbtilesFilePath;
  late Future<MbTilesTileProvider> _tileProviderFuture;
  bool _isTileProviderInitialized = false;
  LatLng? mapCentroid;
  LatLng? currentCoords;

  _OfflineMapWidgetState({required this.mbtilesFilePath}) {
    if (OfflineMapWidget.newMapLoaded &&
        OfflineMapWidget.newMapCoords == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Aquí el FlutterMap ya fue renderizado al menos una vez
        LatLng? coords = await findMBTilesCentroid(mbtilesFilePath);
        if (coords != null) {
          _mapController.move(coords, 16.0);
          OfflineMapWidget.newMapCoords = coords;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (_isTileProviderInitialized) {
      return;
    }
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
                  initialCenter: OfflineMapWidget.newMapCoords ?? MANAGUA2,
                  initialZoom: 14.0,
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
                              loadFromAssets:
                                  path
                                      .split(
                                        path.normalize(layerDescription.path),
                                      )
                                      .firstWhere(
                                        (value) => value.trim() != "",
                                      ) ==
                                  "assets",
                              onLocationTap: widget.onLocationTap,
                              markedPolygons:
                                  layerDescription.path.endsWith(
                                        "_predios.geojson",
                                      )
                                      ? widget.prediosListos
                                      : [],
                            ),
                          )
                          .toList()
                      : []),

                  if (currentCoords != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentCoords!,
                          child: Icon(Icons.location_history),
                          alignment: Alignment.topCenter,
                          height: 50,
                          rotate: true,
                        ),
                      ],
                    ),
                ],
              ),
              Positioned(
                bottom: 16.0,
                right: 16.0,
                child: FloatingActionButton(
                  onPressed: () async {
                    currentCoords = await _getCurrentPosition();
                    if (currentCoords == null) return;
                    _mapController.move(currentCoords!, 18.0);
                    setState(() {});
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
    try {
      mbtilesFilePath = (await getMapFile(filePath: mbtilesFilePath))!.path;
      final result = MbTilesTileProvider.fromPath(path: mbtilesFilePath);
      if (OfflineMapWidget.newMapLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Mapa cargado correctamente!")),
        );
        OfflineMapWidget.newMapLoaded = false;
      }
      return result;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ No fue posible cargar el mapa")),
      );
      return Future.error("❌ No fue posible cargar el mapa");
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
      return null;
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  bool get wantKeepAlive => true;

  Future<LatLng?> _getCurrentPosition() async {
    Position? currentPosition = await _determinePosition();
    if (currentPosition == null) return null;
    return LatLng(currentPosition.latitude, currentPosition.longitude);
  }
}
