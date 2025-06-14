import 'package:flutter/material.dart';
import 'package:inventario/Model/db_general_management.dart' as db;
import 'package:inventario/View/Widgets/dialogs.dart';
import 'package:inventario/ModelView/wrappers.dart';
import 'package:inventario/View/Widgets/countdown_circle.dart';
import 'dart:typed_data';

class EdificioFormController {
  // ++++++++++++++++++ Módulo Edificación ++++++++++++++++++ //
  bool changePredio = false;
  int? idPredio;
  int? noEdificio;
  int? distrito;
  int? cantidadPisos;
  int? cantidadSotanos;
  int? antejardin;
  int? materialFachada;
  int? canoasBajantes;
  String? observacionesEdificacion;

  // ++++++++++++++++++ Módulo Construcción ++++++++++++++++++ //
  int? estadoInmueble;
  Uint8List? imagenConstruccion;
  String? observacionesConstruccion;

  // ++++++++++++++ Módulo Medidores Eléctricos ++++++++++++++ //
  int? cantidadMedidores;
  String? observacionesMedidores;
  final dropdownOptions = {
    "distrito": {
      1: 'Carmen',
      2: 'Merced',
      3: 'Hospital',
      4: 'Catedral',
      5: 'Zapote',
      6: 'San Francisco',
      7: 'Uruca',
      8: 'Mata Redonda',
      9: 'Pavas',
    },
    "antejardin": {
      0: 'No existe',
      1: 'Si existe',
      2: 'En construcción (Código 996)',
      3: 'No aplica (Código 998)',
    },
    "material fachada": {
      1: 'Bloques y Concreto',
      2: 'Prefabricado',
      3: 'Vidrio y Metal',
      4: 'Ladrillo',
      5: 'Madera',
      6: 'Mixto',
      998: 'No aplica (Código 998)',
      999: 'No visible (Código 999)',
    },
    "canoas bajantes": {
      0: 'No existe',
      1: 'Cumple',
      2: 'No cumple',
      998: 'No aplica (Código 998)',
    },
    "estado inmueble": {
      1: "Óptimo",
      2: "Muy Bueno",
      3: "Bueno",
      4: "Intermedio",
      5: "Regular",
      6: "Deficiente",
      7: "Malo",
      8: "Muy Malo",
      9: "Demolición",
      998: "No Aplica (Código 998)",
    },
  };
  final GlobalKey<FormState> formKey;
  final FormGlobalStatusWrapper<int> formGlobalStatus;
  final void Function() formSetStateCallbackFunction;
  List<db.Edificio> edificiosDelPredio = [];
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? snackbaractions;
  bool overridingDelete = false;
  EdificioFormController({
    required this.formKey,
    required this.formGlobalStatus,
    required this.formSetStateCallbackFunction,
  }) {
    if (formGlobalStatus["idPredio"] != null) {
      idPredio = formGlobalStatus["idPredio"];
      db.getAllEdificios(idPredio: formGlobalStatus["idPredio"]).then((
        List<db.Edificio> edificios,
      ) {
        edificiosDelPredio = edificios;
        formSetStateCallbackFunction();
        if (formGlobalStatus["noEdificio"] != null) {
          db
              .getEdificio(
                idPredio: idPredio!,
                noEdificio: formGlobalStatus["noEdificio"]!,
              )
              .then((currentEdificio) {
                if (currentEdificio != null) {
                  noEdificio = formGlobalStatus["noEdificio"];
                  distrito = currentEdificio.distrito;
                  cantidadPisos = currentEdificio.cantidadPisos;
                  cantidadSotanos = currentEdificio.cantidadSotanos;
                  antejardin = currentEdificio.antejardin;
                  materialFachada = currentEdificio.materialFachada;
                  canoasBajantes = currentEdificio.canoasBajantes;
                  observacionesEdificacion =
                      currentEdificio.observacionesEdificacion;
                  estadoInmueble = currentEdificio.estadoInmueble;
                  imagenConstruccion = currentEdificio.imagenConstruccion;
                  observacionesConstruccion =
                      currentEdificio.observacionesConstruccion;
                  cantidadMedidores = currentEdificio.cantidadMedidores;
                  observacionesMedidores =
                      currentEdificio.observacionesMedidores;
                  formSetStateCallbackFunction();
                }
              });
        }
      });
    }
  }

  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++               +++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++                 ++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++    Validacion   ++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++    Formulario   ++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++                 ++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++               +++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //

  Future<void> validateForm(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      db.Edificio? edificioEnElNuevoLugar = await db.getEdificio(
        idPredio: idPredio!,
        noEdificio: noEdificio!,
      );
      db.Predio? newPredio = await db.getPredio(idPredio: idPredio!);

      ///\  /\  /\  /\  /\  /\  /\  /\  /\
      ///\\//\\//\\//\\//\\//\\//\\//\\//\\
      //  \/  \/  \/  \/  \/  \/  \/  \/  \\
      bool nuevoIngreso = formGlobalStatus['noEdificio'] == null;
      bool edicion = !nuevoIngreso;
      bool nadieEnElNuevoLugar = edificioEnElNuevoLugar == null;
      bool alguienEnElNuevoLugar = !nadieEnElNuevoLugar;
      bool mismoPredioDestino = formGlobalStatus["idPredio"] == idPredio;
      bool mismoNoEdificioDestino =
          formGlobalStatus["noEdificio"] == noEdificio;
      bool noExisteElNuevoPredio = newPredio == null;
      bool mismoLugarDeDestino = mismoPredioDestino && mismoNoEdificioDestino;
      int casoEncontrado = -1;

      if (nuevoIngreso) {
        if (noExisteElNuevoPredio) {
          casoEncontrado = 0;
        } else if (nadieEnElNuevoLugar) {
          casoEncontrado = 1;
        } else if (alguienEnElNuevoLugar) {
          casoEncontrado = 2;
        }
      } else if (edicion) {
        if (mismoLugarDeDestino) {
          casoEncontrado = 5;
        } else if (alguienEnElNuevoLugar) {
          casoEncontrado = 4;
        } else if (noExisteElNuevoPredio) {
          casoEncontrado = 6;
        } else if (nadieEnElNuevoLugar) {
          casoEncontrado = 3;
        }
      }

      final newEdificio = db.Edificio(
        idPredio: idPredio!,
        noEdificio: noEdificio!,
        distrito: distrito!,
        cantidadPisos: cantidadPisos!,
        cantidadSotanos: cantidadSotanos!,
        antejardin: antejardin!,
        materialFachada: materialFachada!,
        canoasBajantes: canoasBajantes!,
        observacionesEdificacion: observacionesEdificacion,
        estadoInmueble: estadoInmueble!,
        imagenConstruccion: imagenConstruccion!,
        observacionesConstruccion: observacionesConstruccion,
        cantidadMedidores: cantidadMedidores!,
        observacionesMedidores: observacionesMedidores,
      );
      try {
        switch (casoEncontrado) {
          case 0:
            await showDialog<bool>(
              context: context,
              barrierDismissible: true,
              builder:
                  (dialogContext) => AlertDialog(
                    content: Text(
                      "El predio al que quiere agregar el edificio actual, aún no esta registrado en la BD. Agréguelo primeramente y luego vuelva a intentar agregar el edificio",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(false);
                        },
                        child: Text('Cerrar'),
                      ),
                    ],
                  ),
            );
            return;
          case 1:
            await newEdificio.insertInDB();
          case 2:
            bool? accepted = await showAcceptDismissAlertDialog(
              context,
              message:
                  "Vas a sobrescribir un edificio ya existente. ¿Desea continuar?",
            );
            if (accepted == null || !accepted) return;
            await edificioEnElNuevoLugar!.deleteInDB();
            await newEdificio.insertInDB();
          case 3:
            bool? accepted = await showAcceptDismissAlertDialog(
              context,
              message:
                  "Se cambiará el numero de edificio del edificio actual. ¿Desea continuar?",
            );
            if (accepted == null || !accepted) return;
            newEdificio.updateInDB(
              where: "id_predio = ? and no_edificio = ?",
              whereArgs: [
                formGlobalStatus["idPredio"],
                formGlobalStatus["noEdificio"],
              ],
            );
          case 4:
            bool? accepted = await showAcceptDismissAlertDialog(
              context,
              message:
                  "Vas a sobrescribir un edificio ya existente. ¿Desea continuar?",
            );
            if (accepted == null || !accepted) return;
            await edificioEnElNuevoLugar!.deleteInDB();
            newEdificio.updateInDB(
              where: "id_predio = ? and no_edificio = ?",
              whereArgs: [
                formGlobalStatus["idPredio"],
                formGlobalStatus["noEdificio"],
              ],
            );
          case 5:
            bool? accepted = await showAcceptDismissAlertDialog(
              context,
              message:
                  "Se modificarán los datos de este edificio. ¿Desea continuar?",
            );
            if (accepted == null || !accepted) return;
            newEdificio.updateInDB();
          case 6:
            bool? accepted = await showAcceptDismissAlertDialog(
              context,
              message:
                  "El predio al que se desea mover el edificio actual aún no está en la BD . Debe introducirlo primeramente para luego agregarle edificios",
            );
            if (accepted == null || !accepted) return;
            newEdificio.updateInDB();
            break;
          default:
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('✅ Datos guardados')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error al guardar los datos')));
      }

      formGlobalStatus["noEdificio"] = null;
    }
  }

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++      +++++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++          +++++++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++   Utiles   ++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++          +++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++      +++++++++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  void agregarEdificio() {
    formGlobalStatus["noEdificio"] = null;
  }

  void editarEdificio(int idx) {
    // _imageVersion++;
    formGlobalStatus["noEdificio"] = edificiosDelPredio[idx].noEdificio;
  }

  void eliminarEdificio(BuildContext context, int idx) async {
    var currentEdificio = edificiosDelPredio[idx];
    bool dismissAction = false;
    bool iWasNotOverriden = true;
    if (snackbaractions != null) {
      overridingDelete = true;
      snackbaractions!.close();
    }
    snackbaractions = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Edificio eliminado'),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    dismissAction = true;
                  },
                  child: Text(
                    "Deshacer",
                    style: TextStyle(color: Colors.blue[400]),
                  ),
                ),
                SizedBox(width: 15.0),
                CountdownCircle(duration: Duration(seconds: 5)),
              ],
            ),
          ],
        ),
      ),

      // snackBarAnimationStyle: AnimationStyle(duration: Duration(seconds: 7)),
    );
    final start = DateTime.now();
    while (DateTime.now().difference(start) < Duration(seconds: 5)) {
      await Future.delayed(Duration(milliseconds: 200));
      if (overridingDelete) {
        overridingDelete = false;
        iWasNotOverriden = false;
        break;
      }
      if (dismissAction) {
        snackbaractions!.close();
        snackbaractions = null;
        return;
      }
    }

    ///\  /\  /\  /\  /\  /\  /\  /\  /\
    ///\\//\\//\\//\\//\\//\\//\\//\\//\\
    //  \/  \/  \/  \/  \/  \/  \/  \/  \\
    //            Acciones
    await currentEdificio.deleteInDB();
    if (iWasNotOverriden) {
      snackbaractions = null;
      if (formGlobalStatus["noEdificio"] ==
          edificiosDelPredio[idx].noEdificio) {
        formGlobalStatus["noEdificio"] = null;
      } else {
        formGlobalStatus["noEdificio"] = formGlobalStatus["noEdificio"];
      }
    }
  }
}
