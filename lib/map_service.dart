import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'dart:io';

class MapService {
  Future<void> loadOfflineTiles() async {
    // Verifica si el archivo MBTiles existe en el dispositivo
    File mbtilesFile = File('assets/tiles/mapa.mbtiles');
    if (!mbtilesFile.existsSync()) {
      throw Exception("Archivo MBTiles no encontrado");
    }
  }

  TileProvider getTileProvider() {
    return MBTilesImageProvider(mbtilesDbPath: 'assets/tiles/mapa.mbtiles');
  }
}

class MapaCustomizado extends StatelessWidget {
  const MapaCustomizado({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

final _futureTileProvider = MbTilesTileProvider.fromSource(
  'path/to/file.mbtiles',
);

@override
Widget build(BuildContext context) {
  return FlutterMap(
    options: MapOptions(),
    children: [
      TileLayer(
        // use your awaited MbTilesTileProvider
        tileProvider: tileProvider,
      ),
    ],
  );
}

@override
void dispose() {
  // close mbtiles database
  tileProvider.dispose();
  super.dispose();
}
