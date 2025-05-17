import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

Widget getDebugMap(MbTiles _mbtiles) {
  final metadata = _mbtiles!.getMetadata();
  return Column(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'MBTiles Name: ${metadata.name}, '
          'Format: ${metadata.format}',
        ),
      ),
      Expanded(
        child: FlutterMap(
          options: const MapOptions(
            minZoom: 10,
            maxZoom: 15,
            initialZoom: 10,
            initialCenter: LatLng(12.145643078921182, -86.26495747803298),
          ),
          children: [
            TileLayer(
              tileProvider: MbTilesTileProvider(
                mbtiles: _mbtiles!,
                silenceTileNotFound: true,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
