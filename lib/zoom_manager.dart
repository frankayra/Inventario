// zoom_manager.dart
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ZoomManager {
  void handleZoomSelection(MapController mapController, LatLng point) {
    if (mapController.zoom < 7) {
      mapController.move(point, 8); // Zoom a nivel 2
    } else {
      mapController.move(point, 12); // Zoom a nivel más detallado
    }
  }
}
