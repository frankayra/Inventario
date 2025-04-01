import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> openDB() async {
  final database = openDatabase(
    join(await getDatabasesPath(), 'edificaciones.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE edificaciones(id INTEGER PRIMARY KEY AUTOINCREMENT, distrito TEXT, edificio INTEGER, cantidadPisos INTEGER, cantidadSotanos INTEGER, antejardin TEXT, materialFachada TEXT, canoasBajantes TEXT, observacionesEdificaciones TEXT)',
      );
    },
    version: 1,
  );
  return database;
}

class Edificacion {
  final int? id;
  final String distrito;
  final int edificio;
  final int cantidadPisos;
  final int cantidadSotanos;
  final String antejardin;
  final String materialFachada;
  final String canoasBajantes;
  final String? observacionesEdificaciones;

  Edificacion({
    this.id,
    required this.distrito,
    required this.edificio,
    required this.cantidadPisos,
    required this.cantidadSotanos,
    required this.antejardin,
    required this.materialFachada,
    required this.canoasBajantes,
    this.observacionesEdificaciones,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'distrito': distrito,
      'edificio': edificio,
      'cantidadPisos': cantidadPisos,
      'cantidadSotanos': cantidadSotanos,
      'antejardin': antejardin,
      'materialFachada': materialFachada,
      'canoasBajantes': canoasBajantes,
      'observacionesEdificaciones': observacionesEdificaciones,
    };
  }
}

Future<void> insertEdificacion(Edificacion edificacion) async {
  final db = await openDB();
  await db.insert(
    'edificaciones',
    edificacion.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
