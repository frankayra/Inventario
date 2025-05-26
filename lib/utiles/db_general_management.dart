import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// +++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// +++++++++++++++++ Interacción SQLite ++++++++++++++++ //
// +++++++++++++++++++++++++++++++++++++++++++++++++++++ //
Future<Database> openDB() async {
  final database = openDatabase(
    join(await getDatabasesPath(), 'inventario.db'),
    onCreate: (db, version) {
      return db.execute("""
CREATE TABLE predios(
        id_predio INTEGER PRIMARY KEY, 
        nivelPredio_1 FLOAT NOT NULL,
        nivelPredio_2 FLOAT NOT NULL,
        nivelPredio_3 FLOAT NOT NULL,
        acera INTEGER NOT NULL,
        anchoAcera FLOAT NOT NULL,
        observacionesTerreno TEXT);

CREATE TABLE edificios(
        id_predio INTEGER, 
        no_edificio INTEGER, 
        distrito INTEGER NOT NULL, 
        cantidadPisos INTEGER NOT NULL, 
        cantidadSotanos INTEGER NOT NULL, 
        antejardin INTEGER NOT NULL, 
        materialFachada INTEGER NOT NULL, 
        canoasBajantes INTEGER NOT NULL, 
        observacionesEdificacion TEXT, 
        estadoInmueble INTEGER NOT NULL, 
        observacionesConstruccion TEXT, 
        cantidadMedidores INTEGER NOT NULL, 
        observacionesMedidores TEXT, 
        PRIMARY KEY (id_predio, no_edificio), 
        FOREIGN KEY (id_predio) REFERENCES predios(id_predio) 
          ON DELETE CASCADE);
          
CREATE TABLE propiedades(
        id_predio INTEGER,
        no_edificio INTEGER,
        no_local INTEGER,
        nivelPiso TEXT NOT NULL,
        actividadPrimaria TEXT NOT NULL,
        actividadComplementaria TEXT,
        estadoNegocio TEXT,
        nombreNegocio TEXT,
        cantidadParqueos INTEGER NOT NULL,
        documentoMostrado INTEGER,
        nombrePatentado TEXT,
        numeroPatenteComercial INTEGER,
        cedulaPatentado INTEGER,
        nombreActividadPatente TEXT,
        tieneMasPatentes INTEGER NOT NULL,
        numeroPatente_2 INTEGER,
        tienePermisoSalud INTEGER NOT NULL,
        numeroPermisoSalud TEXT,
        fechaVigenciaPermisoSalud INTEGER,
        codigoCIIUPermisoSalud TEXT,
        seTrataDeLocalMercado INTEGER NOT NULL,
        numeroLocalMercado INTEGER,
        tienePatenteLicores INTEGER NOT NULL,
        numeroPatenteLicores INTEGER,
        areaActividad INTEGER,
        telefonoPatentado INTEGER,
        correoElectronico TEXT,
        cantidadEmpleadosAntesCovid INTEGER,
        cantidadEmpleadosActual INTEGER,
        afectacionesCovidPersonalDesempennoEmpresa TEXT,
        afectacionesCovidSobreVentas TEXT,
        codigoCIUUActividadPrimaria TEXT,
        codigoCIUUActividadComplementaria TEXT,
        observacionesPatentes TEXT,
        imagenDocumentoLegal BLOB),
        PRIMARY KEY(id_predio, no_edificio, no_local),
        FOREIGN KEY (id_predio, no_edificio) REFERENCES predios(id_predio, no_edificio));
          """);
    },
    version: 1,
  );
  return database;
}

abstract class InventarioDbTable {
  final String tableName;
  Map<String, dynamic> toMap();
  const InventarioDbTable(this.tableName);

  Future<void> insertInDB() async {
    final db = await openDB();
    await db.insert(
      this.tableName,
      this.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++++   ++++++++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++         +++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++   PREDIO  ++++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++         +++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++++   ++++++++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
class Predio extends InventarioDbTable {
  final int idPredio;

  // +++++++++++++++++++++ Módulo Terreno ++++++++++++++++++++ //
  final Float nivelPredio1;
  final Float nivelPredio2;
  final Float nivelPredio3;
  final int acera;
  final Float anchoAcera;
  final String? observacionesTerreno;

  Predio({
    required this.idPredio,
    required this.nivelPredio1,
    required this.nivelPredio2,
    required this.nivelPredio3,
    required this.acera,
    required this.anchoAcera,
    this.observacionesTerreno,
  }) : super('predios');

  @override
  Map<String, dynamic> toMap() {
    return {
      'idPredio': idPredio,
      'nivelPredio1': nivelPredio1,
      'nivelPredio2': nivelPredio2,
      'nivelPredio3': nivelPredio3,
      'acera': acera,
      'anchoAcera': anchoAcera,
      'observacionesTerreno': observacionesTerreno,
    };
  }
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++         ++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++             ++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++    Edificio   +++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++             ++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++         ++++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
class Edificio extends InventarioDbTable {
  final int idPredio;

  // ++++++++++++++++++ Módulo Edificación ++++++++++++++++++ //
  final int noEdificio;
  final int distrito;
  final int cantidadPisos;
  final int cantidadSotanos;
  final int antejardin;
  final int materialFachada;
  final int canoasBajantes;
  final String? observacionesEdificacion;

  // ++++++++++++++++++ Módulo Construcción ++++++++++++++++++ //
  final int estadoInmueble;
  final Uint8List imagenConstruccion;
  final String? observacionesConstruccion;

  // ++++++++++++++ Módulo Medidores Eléctricos ++++++++++++++ //
  final int cantidadMedidores;
  final String? observacionesMedidores;

  Edificio({
    required this.idPredio,
    required this.noEdificio,
    required this.distrito,
    required this.cantidadPisos,
    required this.cantidadSotanos,
    required this.antejardin,
    required this.materialFachada,
    required this.canoasBajantes,
    this.observacionesEdificacion,
    required this.estadoInmueble,
    required this.imagenConstruccion,
    this.observacionesConstruccion,
    required this.cantidadMedidores,
    this.observacionesMedidores,
  }) : super('edificios');

  @override
  Map<String, dynamic> toMap() {
    return {
      'id_predio': idPredio,
      'no_edificio': noEdificio,
      'distrito': distrito,
      'cantidadPisos': cantidadPisos,
      'cantidadSotanos': cantidadSotanos,
      'antejardin': antejardin,
      'materialFachada': materialFachada,
      'canoasBajantes': canoasBajantes,
      'observacionesEdificacion': observacionesEdificacion,
      'estadoInmueble': estadoInmueble,
      'imagenConstruccion': imagenConstruccion,
      'observacionesConstruccion': observacionesConstruccion,
      'cantidadMedidores': cantidadMedidores,
      'observacionesMedidores': observacionesMedidores,
    };
  }
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++     +++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++           ++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++  Propiedad  +++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++           ++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++     +++++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

class Propiedad extends InventarioDbTable {
  final int idPredio;
  final int noEdificio;
  final int noLocal;

  // ++++++ Módulo Uso de suelo y Patentes comerciales ++++++ //
  final String nivelPiso;
  final String actividadPrimaria;
  final String? actividadComplementaria;
  final String? estadoNegocio;
  final String? nombreNegocio;
  final int cantidadParqueos;
  final int? documentoMostrado;
  final String? nombrePatentado;
  final int? numeroPatenteComercial;
  final int? cedulaPatentado;
  final String? nombreActividadPatente;
  final bool tieneMasPatentes;
  final int? numeroPatente_2;
  final bool tienePermisoSalud;
  final String? numeroPermisoSalud;
  final int? fechaVigenciaPermisoSalud;
  final String? codigoCIIUPermisoSalud;
  final int seTrataDeLocalMercado;
  final int? numeroLocalMercado;
  final bool tienePatenteLicores;
  final int? numeroPatenteLicores;
  final int? areaActividad;
  final int? telefonoPatentado;
  final String? correoElectronico;
  final int? cantidadEmpleadosAntesCovid;
  final int? cantidadEmpleadosActual;
  final String? afectacionesCovidPersonalDesempennoEmpresa;
  final String? afectacionesCovidSobreVentas;
  final String? codigoCIUUActividadPrimaria;
  final String? codigoCIUUActividadComplementaria;
  final String? observacionesPatentes;
  final Uint8List imagenDocumentoLegal;
  Propiedad({
    required this.idPredio,
    required this.noEdificio,
    required this.noLocal,
    required this.nivelPiso,
    required this.actividadPrimaria,
    this.actividadComplementaria,
    this.estadoNegocio,
    this.nombreNegocio,
    required this.cantidadParqueos,
    this.documentoMostrado,
    this.nombrePatentado,
    this.numeroPatenteComercial,
    this.cedulaPatentado,
    this.nombreActividadPatente,
    required this.tieneMasPatentes,
    this.numeroPatente_2,
    required this.tienePermisoSalud,
    this.numeroPermisoSalud,
    this.fechaVigenciaPermisoSalud,
    this.codigoCIIUPermisoSalud,
    required this.seTrataDeLocalMercado,
    this.numeroLocalMercado,
    required this.tienePatenteLicores,
    this.numeroPatenteLicores,
    this.areaActividad,
    this.telefonoPatentado,
    this.correoElectronico,
    this.cantidadEmpleadosAntesCovid,
    this.cantidadEmpleadosActual,
    this.afectacionesCovidPersonalDesempennoEmpresa,
    this.afectacionesCovidSobreVentas,
    this.codigoCIUUActividadPrimaria,
    this.codigoCIUUActividadComplementaria,
    this.observacionesPatentes,
    required this.imagenDocumentoLegal,
  }) : super('propiedades');

  @override
  Map<String, dynamic> toMap() {
    return {
      'id_predio': idPredio,
      'no_edificio': noEdificio,
      'no_local': noLocal,
      'nivelPiso': nivelPiso,
      'actividadPrimaria': actividadPrimaria,
      'actividadComplementaria': actividadComplementaria,
      'estadoNegocio': estadoNegocio,
      'nombreNegocio': nombreNegocio,
      'cantidadParqueos': cantidadParqueos,
      'documentoMostrado': documentoMostrado,
      'nombrePatentado': nombrePatentado,
      'numeroPatenteComercial': numeroPatenteComercial,
      'cedulaPatentado': cedulaPatentado,
      'nombreActividadPatente': nombreActividadPatente,
      'tieneMasPatentes': tieneMasPatentes,
      'numeroPatente_2': numeroPatente_2,
      'tienePermisoSalud': tienePermisoSalud,
      'numeroPermisoSalud': numeroPermisoSalud,
      'fechaVigenciaPermisoSalud': fechaVigenciaPermisoSalud,
      'codigoCIIUPermisoSalud': codigoCIIUPermisoSalud,
      'seTrataDeLocalMercado': seTrataDeLocalMercado,
      'numeroLocalMercado': numeroLocalMercado,
      'tienePatenteLicores': tienePatenteLicores,
      'numeroPatenteLicores': numeroPatenteLicores,
      'areaActividad': areaActividad,
      'telefonoPatentado': telefonoPatentado,
      'correoElectronico': correoElectronico,
      'cantidadEmpleadosAntesCovid': cantidadEmpleadosAntesCovid,
      'cantidadEmpleadosActual': cantidadEmpleadosActual,
      'afectacionesCovidPersonalDesempennoEmpresa':
          afectacionesCovidPersonalDesempennoEmpresa,
      'afectacionesCovidSobreVentas': afectacionesCovidSobreVentas,
      'codigoCIUUActividadPrimaria': codigoCIUUActividadPrimaria,
      'codigoCIUUActividadComplementaria': codigoCIUUActividadComplementaria,
      'observacionesPatentes': observacionesPatentes,
      'imagenDocumentoLegal': imagenDocumentoLegal,
    };
  }
}



// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++     +++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++           ++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++   QUERIES   +++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++           ++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++     +++++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

// Edificio getEdificio(int idPredio, int noEdificio){
  
// }
// List<Edificio> getAllEdificios()