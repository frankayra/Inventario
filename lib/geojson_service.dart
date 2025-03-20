// geojson_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GeoJsonService {
  List<Polygon> getPolygons() {
    return [
      Polygon(
        points: [
          LatLng(37.78, -122.42),
          LatLng(37.79, -122.43),
          LatLng(37.77, -122.44),
          LatLng(37.76, -122.41),
        ],
        color: const Color.fromRGBO(0, 0, 255, 0.3),
        borderStrokeWidth: 2,
        borderColor: const Color.fromRGBO(0, 0, 255, 1),
      ),
    ];
  }
}
