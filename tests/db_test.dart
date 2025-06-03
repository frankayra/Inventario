import 'package:inventario/utiles/db_general_management.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // For testing on non-Android/iOS
import 'package:path/path.dart';

void main() {
  // Initialize sqflite_common_ffi for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Operations Tests', () {
    // Before each test, open a clean database
    setUp(() async {
      final pathToDB = join(await getDatabasesPath(), 'inventario.db');
      // Ensure a clean database for each test
      if (await databaseExists(pathToDB)) {
        await deleteDatabase(pathToDB);
      }
      // Open the database, which will create tables if they don't exist
      await openDB();
    });

    // After each test, close and delete the database to ensure isolation
    tearDown(() async {
      final pathToDB = join(await getDatabasesPath(), 'inventario.db');
      if (await databaseExists(pathToDB)) {
        await deleteDatabase(pathToDB);
      }
    });

    // Tests
    predioInsertionAndRetreival_test();
    predioUpdate_test();
    predioDelete_test();
    edificioInsertionAndRetreival_test();
    edificioUpdate_test();
    edificioDelete_test();
    propiedadInsertionAndRetreival_test();
    propiedadUpdate_test();
    propiedadDelete_test();
  });
}

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++               +++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++                 ++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++      Predio     ++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++                 ++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++               +++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

Future<void> predioInsertionAndRetreival_test() async {
  test('Predio: Can insert and retrieve a predio', () async {
    final predio = Predio(
      idPredio: 1,
      nivelPredio1: 10.0,
      nivelPredio2: 20.0,
      nivelPredio3: 30.0,
      acera: 1,
      anchoAcera: 1.5,
      observacionesTerreno: 'Observaciones del terreno 1',
    );

    await predio.insertInDB();

    final retrievedPredio = await getPredio(idPredio: 1);
    expect(retrievedPredio, isNotNull);
    expect(retrievedPredio!.idPredio, 1);
    expect(retrievedPredio.nivelPredio1, 10.0);
    expect(retrievedPredio.observacionesTerreno, 'Observaciones del terreno 1');

    final allPredios = await getAllPredios();
    expect(allPredios.length, 1);
    expect(allPredios[0].idPredio, 1);
  });

  test('Predio: getPredio returns null for non-existent predio', () async {
    final retrievedPredio = await getPredio(idPredio: 999);
    expect(retrievedPredio, isNull);
  });

  test(
    'Predio: getAllPredios returns empty list if no predios exist',
    () async {
      final allPredios = await getAllPredios();
      expect(allPredios, isEmpty);
    },
  );
}

Future<void> predioUpdate_test() async {
  test('Predio: Can update an existing predio', () async {
    final predio = Predio(
      idPredio: 1,
      nivelPredio1: 10.0,
      nivelPredio2: 20.0,
      nivelPredio3: 30.0,
      acera: 1,
      anchoAcera: 1.5,
      observacionesTerreno: 'Observaciones iniciales',
    );
    await predio.insertInDB();

    final updatedPredio = Predio(
      idPredio: 1,
      nivelPredio1: 15.0,
      nivelPredio2: 25.0,
      nivelPredio3: 35.0,
      acera: 0,
      anchoAcera: 2.0,
      observacionesTerreno: 'Observaciones actualizadas',
    );
    await updatedPredio.updateInDB();

    final retrievedPredio = await getPredio(idPredio: 1);
    expect(retrievedPredio, isNotNull);
    expect(retrievedPredio!.nivelPredio1, 15.0);
    expect(retrievedPredio.observacionesTerreno, 'Observaciones actualizadas');
    expect(retrievedPredio.acera, 0);
  });
}

Future<void> predioDelete_test() async {
  test('Predio: Can delete a predio', () async {
    final predio = Predio(
      idPredio: 1,
      nivelPredio1: 10.0,
      nivelPredio2: 20.0,
      nivelPredio3: 30.0,
      acera: 1,
      anchoAcera: 1.5,
      observacionesTerreno: 'Predio a eliminar',
    );
    await predio.insertInDB();

    await predio.deleteInDB();

    final retrievedPredio = await getPredio(idPredio: 1);
    expect(retrievedPredio, isNull);
    final allPredios = await getAllPredios();
    expect(allPredios, isEmpty);
  });
}

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++                 +++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++                   ++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++      Edificio     ++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++                   ++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++                 +++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
Future<void> edificioInsertionAndRetreival_test() async {
  test('Edificio: Can insert and retrieve an edificio', () async {
    final predio = Predio(
      idPredio: 1,
      nivelPredio1: 10.0,
      nivelPredio2: 20.0,
      nivelPredio3: 30.0,
      acera: 1,
      anchoAcera: 1.5,
      observacionesTerreno: 'Test Predio',
    );
    await predio.insertInDB();

    final edificio = Edificio(
      idPredio: 1,
      noEdificio: 1,
      distrito: 1,
      cantidadPisos: 3,
      cantidadSotanos: 1,
      antejardin: 1,
      materialFachada: 1,
      canoasBajantes: 1,
      estadoInmueble: 1,
      imagenConstruccion: Uint8List(0),
      cantidadMedidores: 2,
    );
    await edificio.insertInDB();

    final retrievedEdificio = await getEdificio(idPredio: 1, noEdificio: 1);
    expect(retrievedEdificio, isNotNull);
    expect(retrievedEdificio!.idPredio, 1);
    expect(retrievedEdificio.noEdificio, 1);
    expect(retrievedEdificio.cantidadPisos, 3);

    final allEdificios = await getAllEdificios(idPredio: 1);
    expect(allEdificios.length, 1);
    expect(allEdificios[0].noEdificio, 1);
  });

  test(
    'Edificio: getEdificio returns null for non-existent edificio',
    () async {
      final retrievedEdificio = await getEdificio(idPredio: 1, noEdificio: 999);
      expect(retrievedEdificio, isNull);
    },
  );

  test(
    'Edificio: getAllEdificios returns empty list if no edificios for predio',
    () async {
      final predio = Predio(
        idPredio: 1,
        nivelPredio1: 10.0,
        nivelPredio2: 20.0,
        nivelPredio3: 30.0,
        acera: 1,
        anchoAcera: 1.5,
        observacionesTerreno: 'Test Predio',
      );
      await predio.insertInDB();

      final allEdificios = await getAllEdificios(idPredio: 1);
      expect(allEdificios, isEmpty);
    },
  );
}

Future<void> edificioUpdate_test() async {
  test('Edificio: Can update an existing edificio', () async {
    final predio = Predio(
      idPredio: 1,
      nivelPredio1: 10.0,
      nivelPredio2: 20.0,
      nivelPredio3: 30.0,
      acera: 1,
      anchoAcera: 1.5,
      observacionesTerreno: 'Test Predio',
    );
    await predio.insertInDB();

    final edificio = Edificio(
      idPredio: 1,
      noEdificio: 1,
      distrito: 1,
      cantidadPisos: 3,
      cantidadSotanos: 1,
      antejardin: 1,
      materialFachada: 1,
      canoasBajantes: 1,
      estadoInmueble: 1,
      imagenConstruccion: Uint8List(0),
      cantidadMedidores: 2,
    );
    await edificio.insertInDB();

    final updatedEdificio = Edificio(
      idPredio: 1,
      noEdificio: 1,
      distrito: 2,
      cantidadPisos: 5,
      cantidadSotanos: 2,
      antejardin: 0,
      materialFachada: 2,
      canoasBajantes: 0,
      estadoInmueble: 2,
      imagenConstruccion: Uint8List(0),
      cantidadMedidores: 3,
      observacionesEdificacion: 'Edificio actualizado',
    );
    await updatedEdificio.updateInDB();

    final retrievedEdificio = await getEdificio(idPredio: 1, noEdificio: 1);
    expect(retrievedEdificio, isNotNull);
    expect(retrievedEdificio!.distrito, 2);
    expect(retrievedEdificio.cantidadPisos, 5);
    expect(retrievedEdificio.observacionesEdificacion, 'Edificio actualizado');
  });
}

Future<void> edificioDelete_test() async {
  test('Edificio: Can delete an edificio', () async {
    final predio = Predio(
      idPredio: 1,
      nivelPredio1: 10.0,
      nivelPredio2: 20.0,
      nivelPredio3: 30.0,
      acera: 1,
      anchoAcera: 1.5,
      observacionesTerreno: 'Test Predio',
    );
    await predio.insertInDB();

    final edificio = Edificio(
      idPredio: 1,
      noEdificio: 1,
      distrito: 1,
      cantidadPisos: 3,
      cantidadSotanos: 1,
      antejardin: 1,
      materialFachada: 1,
      canoasBajantes: 1,
      estadoInmueble: 1,
      imagenConstruccion: Uint8List(0),
      cantidadMedidores: 2,
    );
    await edificio.insertInDB();

    await edificio.deleteInDB();

    final retrievedEdificio = await getEdificio(idPredio: 1, noEdificio: 1);
    expect(retrievedEdificio, isNull);
    final allEdificios = await getAllEdificios(idPredio: 1);
    expect(allEdificios, isEmpty);
  });

  test(
    'Edificio: Deleting predio cascades to delete related edificios',
    () async {
      final predio = Predio(
        idPredio: 1,
        nivelPredio1: 10.0,
        nivelPredio2: 20.0,
        nivelPredio3: 30.0,
        acera: 1,
        anchoAcera: 1.5,
        observacionesTerreno: 'Test Predio',
      );
      await predio.insertInDB();

      final edificio = Edificio(
        idPredio: 1,
        noEdificio: 1,
        distrito: 1,
        cantidadPisos: 3,
        cantidadSotanos: 1,
        antejardin: 1,
        materialFachada: 1,
        canoasBajantes: 1,
        estadoInmueble: 1,
        imagenConstruccion: Uint8List(0),
        cantidadMedidores: 2,
      );
      await edificio.insertInDB();

      await predio.deleteInDB(); // Delete the parent predio
      Future.delayed(Duration(milliseconds: 200));

      final retrievedEdificio = await getEdificio(idPredio: 1, noEdificio: 1);
      expect(retrievedEdificio, isNull);
    },
  );
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++                  +++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++                    ++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++      Propiedad     ++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++                    ++++++++++++++++++++++++++ //
// +++++++++++++++++++++++++                  +++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

Future<void> propiedadInsertionAndRetreival_test() async {
  test('Propiedad: Can insert and retrieve a propiedad', () async {
    final predio = Predio(
      idPredio: 1,
      nivelPredio1: 10.0,
      nivelPredio2: 20.0,
      nivelPredio3: 30.0,
      acera: 1,
      anchoAcera: 1.5,
      observacionesTerreno: 'Test Predio',
    );
    await predio.insertInDB();

    final edificio = Edificio(
      idPredio: 1,
      noEdificio: 1,
      distrito: 1,
      cantidadPisos: 3,
      cantidadSotanos: 1,
      antejardin: 1,
      materialFachada: 1,
      canoasBajantes: 1,
      estadoInmueble: 1,
      imagenConstruccion: Uint8List(0),
      cantidadMedidores: 2,
    );
    await edificio.insertInDB();

    final propiedad = Propiedad(
      idPredio: 1,
      noEdificio: 1,
      noLocal: 1,
      nivelPiso: 'Planta Baja',
      actividadPrimaria: 'Comercio',
      cantidadParqueos: 2,
      tieneMasPatentes: false,
      tienePermisoSalud: true,
      seTrataDeLocalMercado: false,
      tienePatenteLicores: false,
      imagenDocumentoLegal: Uint8List(0),
      nombreNegocio: 'Mi Tienda',
    );
    await propiedad.insertInDB();

    final retrievedPropiedad = await getPropiedad(
      idPredio: 1,
      noEdificio: 1,
      noLocal: 1,
    );
    expect(retrievedPropiedad, isNotNull);
    expect(retrievedPropiedad!.idPredio, 1);
    expect(retrievedPropiedad.noEdificio, 1);
    expect(retrievedPropiedad.noLocal, 1);
    expect(retrievedPropiedad.nombreNegocio, 'Mi Tienda');

    final allPropiedades = await getAllPropiedades(idPredio: 1, noEdificio: 1);
    expect(allPropiedades.length, 1);
    expect(allPropiedades[0].noLocal, 1);
  });

  test(
    'Propiedad: getPropiedad returns null for non-existent propiedad',
    () async {
      final retrievedPropiedad = await getPropiedad(
        idPredio: 1,
        noEdificio: 1,
        noLocal: 999,
      );
      expect(retrievedPropiedad, isNull);
    },
  );

  test(
    'Propiedad: getAllPropiedades returns empty list if no propiedades for edificio',
    () async {
      final predio = Predio(
        idPredio: 1,
        nivelPredio1: 10.0,
        nivelPredio2: 20.0,
        nivelPredio3: 30.0,
        acera: 1,
        anchoAcera: 1.5,
        observacionesTerreno: 'Test Predio',
      );
      await predio.insertInDB();

      final edificio = Edificio(
        idPredio: 1,
        noEdificio: 1,
        distrito: 1,
        cantidadPisos: 3,
        cantidadSotanos: 1,
        antejardin: 1,
        materialFachada: 1,
        canoasBajantes: 1,
        estadoInmueble: 1,
        imagenConstruccion: Uint8List(0),
        cantidadMedidores: 2,
      );
      await edificio.insertInDB();

      final allPropiedades = await getAllPropiedades(
        idPredio: 1,
        noEdificio: 1,
      );
      expect(allPropiedades, isEmpty);
    },
  );
}

Future<void> propiedadUpdate_test() async {
  test('Propiedad: Can update an existing propiedad', () async {
    final predio = Predio(
      idPredio: 1,
      nivelPredio1: 10.0,
      nivelPredio2: 20.0,
      nivelPredio3: 30.0,
      acera: 1,
      anchoAcera: 1.5,
      observacionesTerreno: 'Test Predio',
    );
    await predio.insertInDB();

    final edificio = Edificio(
      idPredio: 1,
      noEdificio: 1,
      distrito: 1,
      cantidadPisos: 3,
      cantidadSotanos: 1,
      antejardin: 1,
      materialFachada: 1,
      canoasBajantes: 1,
      estadoInmueble: 1,
      imagenConstruccion: Uint8List(0),
      cantidadMedidores: 2,
    );
    await edificio.insertInDB();

    final propiedad = Propiedad(
      idPredio: 1,
      noEdificio: 1,
      noLocal: 1,
      nivelPiso: 'Planta Baja',
      actividadPrimaria: 'Comercio',
      cantidadParqueos: 2,
      tieneMasPatentes: false,
      tienePermisoSalud: true,
      seTrataDeLocalMercado: false,
      tienePatenteLicores: false,
      imagenDocumentoLegal: Uint8List(0),
      nombreNegocio: 'Mi Tienda',
      actividadComplementaria: 'Ventas online',
    );
    await propiedad.insertInDB();

    final updatedPropiedad = Propiedad(
      idPredio: 1,
      noEdificio: 1,
      noLocal: 1,
      nivelPiso: 'Segundo Piso',
      actividadPrimaria: 'Servicios',
      cantidadParqueos: 3,
      tieneMasPatentes: true,
      tienePermisoSalud: false,
      seTrataDeLocalMercado: true,
      tienePatenteLicores: true,
      imagenDocumentoLegal: Uint8List(0),
      nombreNegocio: 'Mi Servicio',
      actividadComplementaria: 'Consultoría',
      telefonoPatentado: 12345678,
    );
    await updatedPropiedad.updateInDB();

    final retrievedPropiedad = await getPropiedad(
      idPredio: 1,
      noEdificio: 1,
      noLocal: 1,
    );
    expect(retrievedPropiedad, isNotNull);
    expect(retrievedPropiedad!.nivelPiso, 'Segundo Piso');
    expect(retrievedPropiedad.nombreNegocio, 'Mi Servicio');
    expect(retrievedPropiedad.telefonoPatentado, 12345678);
  });
}

Future<void> propiedadDelete_test() async {
  test('Propiedad: Can delete a propiedad', () async {
    final predio = Predio(
      idPredio: 1,
      nivelPredio1: 10.0,
      nivelPredio2: 20.0,
      nivelPredio3: 30.0,
      acera: 1,
      anchoAcera: 1.5,
      observacionesTerreno: 'Test Predio',
    );
    await predio.insertInDB();

    final edificio = Edificio(
      idPredio: 1,
      noEdificio: 1,
      distrito: 1,
      cantidadPisos: 3,
      cantidadSotanos: 1,
      antejardin: 1,
      materialFachada: 1,
      canoasBajantes: 1,
      estadoInmueble: 1,
      imagenConstruccion: Uint8List(0),
      cantidadMedidores: 2,
    );
    await edificio.insertInDB();

    final propiedad = Propiedad(
      idPredio: 1,
      noEdificio: 1,
      noLocal: 1,
      nivelPiso: 'Planta Baja',
      actividadPrimaria: 'Comercio',
      cantidadParqueos: 2,
      tieneMasPatentes: false,
      tienePermisoSalud: true,
      seTrataDeLocalMercado: false,
      tienePatenteLicores: false,
      imagenDocumentoLegal: Uint8List(0),
    );
    await propiedad.insertInDB();

    await propiedad.deleteInDB();

    final retrievedPropiedad = await getPropiedad(
      idPredio: 1,
      noEdificio: 1,
      noLocal: 1,
    );
    expect(retrievedPropiedad, isNull);
    final allPropiedades = await getAllPropiedades(idPredio: 1, noEdificio: 1);
    expect(allPropiedades, isEmpty);
  });

  test(
    'Propiedad: Deleting edificio cascades to delete related propiedades',
    () async {
      final predio = Predio(
        idPredio: 1,
        nivelPredio1: 10.0,
        nivelPredio2: 20.0,
        nivelPredio3: 30.0,
        acera: 1,
        anchoAcera: 1.5,
        observacionesTerreno: 'Test Predio',
      );
      await predio.insertInDB();

      final edificio = Edificio(
        idPredio: 1,
        noEdificio: 1,
        distrito: 1,
        cantidadPisos: 3,
        cantidadSotanos: 1,
        antejardin: 1,
        materialFachada: 1,
        canoasBajantes: 1,
        estadoInmueble: 1,
        imagenConstruccion: Uint8List(0),
        cantidadMedidores: 2,
      );
      await edificio.insertInDB();

      final propiedad = Propiedad(
        idPredio: 1,
        noEdificio: 1,
        noLocal: 1,
        nivelPiso: 'Planta Baja',
        actividadPrimaria: 'Comercio',
        cantidadParqueos: 2,
        tieneMasPatentes: false,
        tienePermisoSalud: true,
        seTrataDeLocalMercado: false,
        tienePatenteLicores: false,
        imagenDocumentoLegal: Uint8List(0),
      );
      await propiedad.insertInDB();

      await edificio.deleteInDB(); // Delete the parent edificio

      final retrievedPropiedad = await getPropiedad(
        idPredio: 1,
        noEdificio: 1,
        noLocal: 1,
      );
      expect(retrievedPropiedad, isNull);
    },
  );
}
