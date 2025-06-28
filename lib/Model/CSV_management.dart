import 'dart:io';
import 'package:excel/excel.dart';

class LicenciaDB {
  Map<int, Licencia> _licencias = {};
  LicenciaDB.fromCSV([
    String csv_path =
        "/storage/emulated/0/CADIC/Licencias comerciales/maestro_licencias_comerciales.xlsx",
  ]) {
    _licencias = leerExcel<Licencia>(
      csv_path: csv_path,
      fromMap: (row) {
        try {
          int a = int.parse(row["Patente comercial"].toString());
          return (id: a, tuple: Licencia.fromMap(row));
        } catch (e) {
          return null;
        }
      },
    );
  }
  Licencia? operator [](int id) => _licencias[id];
}

class Licencia {
  final String actividadPrimaria;
  final String nombreNegocio;
  final int cedulaPatentado;

  Licencia({
    required this.actividadPrimaria,
    required this.nombreNegocio,
    required this.cedulaPatentado,
  });
  factory Licencia.fromMap(Map<String, dynamic> map) {
    return Licencia(
      actividadPrimaria: map['Actividad Primaria'].toString(),
      nombreNegocio: map['Nombre del Negocio'].toString(),
      cedulaPatentado:
          double.parse(map['Cédula del Patentado'].toString()).toInt(),
    );
  }
}

///
///
///
///
///
///
///

Map<int, T> leerExcel<T>({
  required String csv_path,
  required ({int id, T tuple})? Function(Map<String, dynamic> row) fromMap,
}) {
  File csv_file = File(csv_path);
  if (!csv_file.existsSync()) return {};
  final bytes = csv_file.readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);

  final sheet = excel.tables[excel.tables.keys.first];
  if (sheet == null || sheet.rows.isEmpty) {
    return {};
  }

  // Leer cabeceras
  final headers =
      sheet.rows.first.map((cell) => cell?.value?.toString() ?? '').toList();
  final entities = <int, T>{};
  print("headers: ${headers}");

  for (int i = 1; i < sheet.rows.length; i++) {
    final row = sheet.rows[i];
    final dataMap = <String, dynamic>{};

    for (int j = 0; j < headers.length && j < row.length; j++) {
      dataMap[headers[j]] = row[j]?.value;
    }

    final id_tuple_pair = fromMap(dataMap);
    if (id_tuple_pair == null) continue;
    entities[id_tuple_pair.id] = id_tuple_pair.tuple;
  }

  return entities;
}
