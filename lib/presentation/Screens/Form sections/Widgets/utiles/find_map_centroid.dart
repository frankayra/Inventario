import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<LatLng?> findMBTilesCentroid(String rutaMBTiles) async {
  // Abrimos el archivo MBTiles como base de datos SQLite
  Database db = await openDatabase(rutaMBTiles);

  try {
    // Primero intentamos leer el 'center' directamente
    List<Map<String, dynamic>> resultadoCenter = await db.rawQuery(
      "SELECT value FROM metadata WHERE name = 'center'",
    );

    if (resultadoCenter.isNotEmpty) {
      String centerStr = resultadoCenter.first['value'];
      List<String> partes = centerStr.split(',');

      double lon = double.parse(partes[0]);
      double lat = double.parse(partes[1]);

      await db.close();
      return LatLng(lat, lon);
    }

    // Si no existe 'center', intentamos calcularlo a partir de 'bounds'
    List<Map<String, dynamic>> resultadoBounds = await db.rawQuery(
      "SELECT value FROM metadata WHERE name = 'bounds'",
    );

    if (resultadoBounds.isNotEmpty) {
      String boundsStr = resultadoBounds.first['value'];
      List<String> partes = boundsStr.split(',');

      double minLon = double.parse(partes[0]);
      double minLat = double.parse(partes[1]);
      double maxLon = double.parse(partes[2]);
      double maxLat = double.parse(partes[3]);

      double centroLon = (minLon + maxLon) / 2;
      double centroLat = (minLat + maxLat) / 2;

      await db.close();
      return LatLng(centroLat, centroLon);
    }

    await db.close();
    return null; // No se encontró ni center ni bounds
  } catch (e) {
    await db.close();
    return null;
  }
}
