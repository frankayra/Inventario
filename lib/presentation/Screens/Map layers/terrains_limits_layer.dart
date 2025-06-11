import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:geojson/geojson.dart';

class DelimitationsLayer extends StatefulWidget {
  final String geoJsonPath;
  final Color borderColor;
  final Color locationDoneBackground = const Color.fromARGB(104, 76, 175, 79);
  final bool loadFromAssets;
  final void Function(int idPredio)? onLocationTap;
  final List<int>? markedPolygons;

  const DelimitationsLayer({
    super.key,
    required this.geoJsonPath,
    required this.borderColor,
    required this.loadFromAssets,
    this.onLocationTap,
    this.markedPolygons,
  });

  @override
  State<DelimitationsLayer> createState() => _DelimitationsLayerState();
}

class _DelimitationsLayerState extends State<DelimitationsLayer> {
  List<Polygon> _polygons = [];
  List<Marker> _centroids = [];

  @override
  void initState() {
    super.initState();
    _loadGeoJsonData();
  }

  Future<void> _loadGeoJsonData() async {
    try {
      final String data =
          widget.loadFromAssets
              ? await rootBundle.loadString(widget.geoJsonPath)
              : await File(widget.geoJsonPath).readAsString();
      final geoJson = jsonDecode(data);
      if (geoJson['type'] == 'FeatureCollection') {
        List<Polygon> polygons = [];
        List<Marker> markers = [];

        for (var feature in geoJson['features']) {
          final geometryType = feature['geometry']['type'];
          final coordinates = feature['geometry']['coordinates'];
          final properties =
              feature['properties']
                  as Map<String, dynamic>?; // Acceder a las propiedades

          if (geometryType == 'Polygon') {
            double lat = 0;
            double lon = 0;
            for (var polygonCoordsList in coordinates) {
              List<LatLng> points = [];
              for (var coord in polygonCoordsList) {
                points.add(
                  LatLng(coord[1], coord[0]),
                ); // GeoJSON is [longitude, latitude]
                lat += coord[1];
                lon += coord[0];
              }
              LatLng coordinatesCentroid = LatLng(
                lat / points.length,
                lon / points.length,
              );
              polygons.add(
                Polygon(
                  points: points,
                  // color: ,
                  borderColor:
                      widget.markedPolygons != null &&
                              properties != null &&
                              widget.markedPolygons!.contains(
                                properties["localizacion"],
                              )
                          ? widget.locationDoneBackground
                          : widget.borderColor,
                  color:
                      widget.markedPolygons != null &&
                              properties != null &&
                              widget.markedPolygons!.contains(
                                properties["localizacion"],
                              )
                          ? widget.locationDoneBackground
                          : Colors.transparent,
                  borderStrokeWidth: 2,

                  // Puedes usar las propiedades aquí para personalizar cada polígono
                ),
              );
              if (properties != null && properties.isNotEmpty) {
                Widget markerToShow;
                double markerWidth, markerHeight;
                if (properties["localizacion"] != null) {
                  markerToShow = IconButton(
                    onPressed: () {
                      if (widget.onLocationTap != null) {
                        widget.onLocationTap!(properties["localizacion"]);
                      }
                    },
                    icon: Icon(Icons.circle),
                  );
                  markerWidth = 120;
                  markerHeight = 50;
                } else {
                  markerToShow = Text(
                    // properties.entries.map((entry)=>"${entry.key}: ${entry.value}").join("\n"),
                    properties.entries
                        .map((entry) => "${entry.value}")
                        .join("\n"),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      backgroundColor: Colors.white70,
                    ),
                  );
                  markerWidth = 30;
                  markerHeight = 30;
                }
                markers.add(
                  Marker(
                    width: markerWidth,
                    height: markerHeight,
                    point: coordinatesCentroid,
                    child: Container(
                      alignment: Alignment.center,
                      child: markerToShow,
                    ),
                  ),
                );
              }
            }
          }
        }
        setState(() {
          _centroids = markers;
          _polygons = polygons;
        });
      }
    } catch (e) {
      print('El formato del archivo de limites no es correcto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_polygons.isNotEmpty) PolygonLayer(polygons: _polygons),
        if (_centroids.isNotEmpty) MarkerLayer(markers: _centroids),
      ],
    );
  }
}
