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
  final bool loadFromAssets;

  const DelimitationsLayer({
    super.key,
    required this.geoJsonPath,
    required this.borderColor,
    required this.loadFromAssets,
  });

  @override
  State<DelimitationsLayer> createState() => _DelimitationsLayerState();
}

class _DelimitationsLayerState extends State<DelimitationsLayer> {
  List<Polygon> _polygons = [];
  List<Polyline> _polylines = [];
  List<Marker> _markers = [];

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
      print(
        "Se cargo satisfactoriamente el geojson desde la ruta ${widget.geoJsonPath}",
      );
      if (geoJson['type'] == 'FeatureCollection') {
        List<Polygon> polygons = [];
        List<Polyline> polylines = [];
        List<Marker> markers = [];

        for (var feature in geoJson['features']) {
          final geometryType = feature['geometry']['type'];
          final coordinates = feature['geometry']['coordinates'];
          final properties =
              feature['properties']
                  as Map<String, dynamic>?; // Acceder a las propiedades

          if (geometryType == 'Polygon') {
            for (var polygonCoordsList in coordinates) {
              List<LatLng> points = [];
              for (var coord in polygonCoordsList) {
                points.add(
                  LatLng(coord[1], coord[0]),
                ); // GeoJSON is [longitude, latitude]
              }
              polygons.add(
                Polygon(
                  points: points,
                  // color: Colors.blue.withOpacity(0.5),
                  borderColor: widget.borderColor,
                  // color: widget.borderColor.withOpacity(0.2),
                  borderStrokeWidth: 2,
                  // Puedes usar las propiedades aquí para personalizar cada polígono
                  // data: properties,
                ),
              );
            }
          } else if (geometryType == 'LineString') {
            List<LatLng> points = [];
            for (var coord in coordinates) {
              points.add(LatLng(coord[1], coord[0]));
            }
            polylines.add(
              Polyline(
                points: points,
                color: widget.borderColor,
                strokeWidth: 3,
                // Puedes usar las propiedades aquí para personalizar cada polilínea
                // data: properties,
              ),
            );
          } else if (geometryType == 'Point') {
            markers.add(
              Marker(
                point: LatLng(coordinates[1], coordinates[0]),
                width: 20,
                height: 20,
                child: Icon(Icons.location_pin, color: widget.borderColor),
                // Puedes usar las propiedades aquí para personalizar cada marcador
                // data: properties,
              ),
            );
          }
        }
        setState(() {
          _polygons = polygons;
          _polylines = polylines;
          _markers = markers;
        });
      }
    } catch (e) {
      print('No se encontraron delimitaciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_polygons.isNotEmpty) PolygonLayer(polygons: _polygons),
        if (_polylines.isNotEmpty) PolylineLayer(polylines: _polylines),
        if (_markers.isNotEmpty) MarkerLayer(markers: _markers),
      ],
    );
  }
}
