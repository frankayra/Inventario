import 'package:flutter/material.dart';
import 'package:inventario/Model/db_general_management.dart' as db;
import 'package:inventario/View/Widgets/dialogs.dart';
import 'package:inventario/ModelView/wrappers.dart';
import 'package:inventario/View/Widgets/countdown_circle.dart';
import 'dart:typed_data';

class PropiedadFormController {
  // ++++++ Módulo Uso de suelo y Patentes Comerciales ++++++ //
  bool changeEdificio = false;
  int? idPredio;
  int? noEdificio;
  int? noLocal;
  String? nivelPiso;
  String? actividadPrimaria;
  String? actividadComplementaria;
  int? estadoNegocio;
  String? nombreNegocio;
  int? cantidadParqueos;
  int? documentoMostrado;
  String? nombrePatentado;
  int? numeroPatenteComercial;
  int? cedulaPatentado;
  String? nombreActividadPatente;
  bool tieneMasPatentes = false;
  int? numeroPatente_2;
  bool tienePermisoSalud = false;
  String? numeroPermisoSalud;
  int? fechaVigenciaPermisoSalud;
  String? codigoCIIUPermisoSalud;
  bool seTrataDeLocalMercado = false;
  int? numeroLocalMercado;
  bool tienePatenteLicores = false;
  int? numeroPatenteLicores;
  int? areaActividad;
  int? telefonoPatentado;
  String? correoElectronico;
  int? cantidadEmpleadosAntesCovid;
  int? cantidadEmpleadosActual;
  String? afectacionesCovidPersonalDesempennoEmpresa;
  String? afectacionesCovidSobreVentas;
  List<int> afectacionesCovidPersonalDesempennoEmpresaList = [];
  List<int> afectacionesCovidSobreVentasList = [];
  String? codigoCIIUActividadPrimaria;
  String? codigoCIIUActividadComplementaria;
  String? observacionesPatentes;
  Uint8List? imagenDocumentoLegal;
  final dropdownOptions = {
    "estadoNegocio": {
      1: 'En operación',
      2: 'Cierre temporal',
      3: 'Desocupado con Rótulo SE ALQUILA',
      4: 'Cierre total',
      5: 'Ha modificado la actividad \n      autorizada(EXPRESS u otra actividad)',
    },
    "documentoMostrado": {
      1: 'Certificado Patente',
      2: 'Recibo al día(Menos de dos meses de atraso)',
      3: 'Recibo atrasado(Con más de dos meses de atraso)',
      4: 'Certificado Trámite "CT". Indicar el número',
      5: 'No muestra documentos de patente',
    },
    "areaActividad": {
      1: 'Menos de 50m²',
      2: '51 a 100m²',
      3: '101 a 200m²',
      4: '200 a 400m²',
      5: '400 a 1000m²',
      6: 'Más de 1000m²',
      998: 'No aplica (Código 998)',
      999: 'No visible (Código 999)',
    },
    "afectacionesCovidPersonalDesempennoEmpresa": {
      1: 'Despido de empleados',
      2: 'Reducción jornada laboral',
      3: 'Suspensión del contrato laboral',
      4: 'Se adelantaron vacaciones',
      5: 'Se empezó a trabajar por turnos',
      6: 'Se aumentaron las jornadas',
      7: 'Se implementó modalidad de teletrabajo',
      8: 'Planea contratar en los próximos 6 meses',
      9: 'Ha reinventado su negocio a pedidos virtuales',
      10:
          'Aumento de precios de insumos y materias primas(combustibles, abarrotes, servicios públicos).',
    },
    "afectacionesCovidSobreVentas": {
      1: 'Ingresó "0" ante la afectación de una orden sanitaria',
      2: 'Reducción de los ingresos entre un 50-90%',
      3: 'Reducción de los ingresos entre un 20-50%',
      4: 'Se mantuvieron dentro de lo esperado',
      5: 'Aumentaron',
      6: 'NS-NR',
    },
  };
  final GlobalKey<FormState> formKey;
  final FormGlobalStatusWrapper<int> formGlobalStatus;
  final void Function() formSetStateCallbackFunction;
  List<db.Propiedad> propiedadesDelEdificio = [];
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? snackbaractions;
  bool overridingDelete = false;
  PropiedadFormController({
    required this.formKey,
    required this.formGlobalStatus,
    required this.formSetStateCallbackFunction,
  }) {
    if (formGlobalStatus["idPredio"] != null &&
        formGlobalStatus["noEdificio"] != null) {
      idPredio = formGlobalStatus["idPredio"];
      noEdificio = formGlobalStatus["noEdificio"];
      db
          .getAllPropiedades(
            idPredio: formGlobalStatus["idPredio"],
            noEdificio: formGlobalStatus["noEdificio"],
          )
          .then((List<db.Propiedad> propiedades) {
            propiedadesDelEdificio = propiedades;
            formSetStateCallbackFunction();
            if (formGlobalStatus["noLocal"] != null) {
              db
                  .getPropiedad(
                    idPredio: idPredio!,
                    noEdificio: noEdificio!,
                    noLocal: formGlobalStatus["noLocal"]!,
                  )
                  .then((currentPropiedad) {
                    if (currentPropiedad != null) {
                      noLocal = formGlobalStatus["noLocal"];
                      nivelPiso = currentPropiedad.nivelPiso;
                      actividadPrimaria = currentPropiedad.actividadPrimaria;
                      actividadComplementaria =
                          currentPropiedad.actividadComplementaria;
                      estadoNegocio = currentPropiedad.estadoNegocio;
                      nombreNegocio = currentPropiedad.nombreNegocio;
                      cantidadParqueos = currentPropiedad.cantidadParqueos;
                      documentoMostrado = currentPropiedad.documentoMostrado;
                      nombrePatentado = currentPropiedad.nombrePatentado;
                      numeroPatenteComercial =
                          currentPropiedad.numeroPatenteComercial;
                      cedulaPatentado = currentPropiedad.cedulaPatentado;
                      nombreActividadPatente =
                          currentPropiedad.nombreActividadPatente;
                      tieneMasPatentes = currentPropiedad.tieneMasPatentes;
                      numeroPatente_2 = currentPropiedad.numeroPatente_2;
                      tienePermisoSalud = currentPropiedad.tienePermisoSalud;
                      numeroPermisoSalud = currentPropiedad.numeroPermisoSalud;
                      fechaVigenciaPermisoSalud =
                          currentPropiedad.fechaVigenciaPermisoSalud;
                      codigoCIIUPermisoSalud =
                          currentPropiedad.codigoCIIUPermisoSalud;
                      seTrataDeLocalMercado =
                          currentPropiedad.seTrataDeLocalMercado;
                      numeroLocalMercado = currentPropiedad.numeroLocalMercado;
                      tienePatenteLicores =
                          currentPropiedad.tienePatenteLicores;
                      numeroPatenteLicores =
                          currentPropiedad.numeroPatenteLicores;
                      areaActividad = currentPropiedad.areaActividad;
                      telefonoPatentado = currentPropiedad.telefonoPatentado;
                      correoElectronico = currentPropiedad.correoElectronico;
                      cantidadEmpleadosAntesCovid =
                          currentPropiedad.cantidadEmpleadosAntesCovid;
                      cantidadEmpleadosActual =
                          currentPropiedad.cantidadEmpleadosActual;
                      afectacionesCovidPersonalDesempennoEmpresa =
                          currentPropiedad
                              .afectacionesCovidPersonalDesempennoEmpresa;
                      afectacionesCovidSobreVentas =
                          currentPropiedad.afectacionesCovidSobreVentas;
                      codigoCIIUActividadPrimaria =
                          currentPropiedad.codigoCIUUActividadPrimaria;
                      codigoCIIUActividadComplementaria =
                          currentPropiedad.codigoCIUUActividadComplementaria;
                      observacionesPatentes =
                          currentPropiedad.observacionesPatentes;
                      imagenDocumentoLegal =
                          currentPropiedad.imagenDocumentoLegal;

                      if (afectacionesCovidPersonalDesempennoEmpresa != null) {
                        List<String> stringValues =
                            afectacionesCovidPersonalDesempennoEmpresa!.split(
                              ", ",
                            );

                        for (var entry
                            in dropdownOptions["afectacionesCovidPersonalDesempennoEmpresa"]!
                                .entries) {
                          if (stringValues.contains(entry.value)) {
                            afectacionesCovidPersonalDesempennoEmpresaList.add(
                              entry.key,
                            );
                          }
                        }
                      }
                      if (afectacionesCovidSobreVentas != null) {
                        List<String> stringValues =
                            afectacionesCovidSobreVentas!.split(", ");

                        for (var entry
                            in dropdownOptions["afectacionesCovidSobreVentas"]!
                                .entries) {
                          if (stringValues.contains(entry.value)) {
                            afectacionesCovidSobreVentasList.add(entry.key);
                          }
                        }
                      }
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

  void validateForm(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      db.Propiedad? propiedadEnElNuevoLugar = await db.getPropiedad(
        idPredio: formGlobalStatus["idPredio"]!,
        noEdificio: noEdificio!,
        noLocal: noLocal!,
      );

      ///\  /\  /\  /\  /\  /\  /\  /\  /\
      ///\\//\\//\\//\\//\\//\\//\\//\\//\\
      //  \/  \/  \/  \/  \/  \/  \/  \/  \\
      bool nuevoIngreso = formGlobalStatus['noLocal'] == null;
      bool edicion = !nuevoIngreso;
      bool nadieEnElNuevoLugar = propiedadEnElNuevoLugar == null;
      bool alguienEnElNuevoLugar = !nadieEnElNuevoLugar;
      bool mismoLugarDeDestino =
          formGlobalStatus["idPredio"] == idPredio &&
          formGlobalStatus["noEdificio"] == noEdificio &&
          formGlobalStatus["noLocal"] == noLocal;
      int casoEncontrado = -1;

      if (nuevoIngreso) {
        if (nadieEnElNuevoLugar) {
          casoEncontrado = 1;
        } else if (alguienEnElNuevoLugar) {
          casoEncontrado = 2;
        }
      } else if (edicion) {
        if (mismoLugarDeDestino) {
          casoEncontrado = 5;
        } else if (alguienEnElNuevoLugar) {
          casoEncontrado = 4;
        } else if (nadieEnElNuevoLugar) {
          casoEncontrado = 3;
        }
      }

      final newPropiedad = db.Propiedad(
        idPredio: idPredio!,
        noEdificio: noEdificio!,
        noLocal: noLocal!,
        nivelPiso: nivelPiso!,
        actividadPrimaria: actividadPrimaria!,
        actividadComplementaria: actividadComplementaria,
        estadoNegocio: estadoNegocio,
        nombreNegocio: nombreNegocio,
        cantidadParqueos: cantidadParqueos!,
        documentoMostrado: documentoMostrado,
        nombrePatentado: nombrePatentado,
        numeroPatenteComercial: numeroPatenteComercial,
        cedulaPatentado: cedulaPatentado,
        nombreActividadPatente: nombreActividadPatente,
        tieneMasPatentes: tieneMasPatentes,
        numeroPatente_2: tieneMasPatentes ? numeroPatente_2 : null,
        tienePermisoSalud: tienePermisoSalud,
        numeroPermisoSalud: tienePermisoSalud ? numeroPermisoSalud : null,
        fechaVigenciaPermisoSalud:
            tienePermisoSalud ? fechaVigenciaPermisoSalud : null,
        codigoCIIUPermisoSalud:
            tienePermisoSalud ? codigoCIIUPermisoSalud : null,
        seTrataDeLocalMercado: seTrataDeLocalMercado,
        numeroLocalMercado: seTrataDeLocalMercado ? numeroLocalMercado : null,
        tienePatenteLicores: tienePatenteLicores,
        numeroPatenteLicores: tienePatenteLicores ? numeroPatenteLicores : null,
        areaActividad: areaActividad,
        telefonoPatentado: telefonoPatentado,
        correoElectronico: correoElectronico,
        cantidadEmpleadosAntesCovid: cantidadEmpleadosAntesCovid,
        cantidadEmpleadosActual: cantidadEmpleadosActual,
        afectacionesCovidPersonalDesempennoEmpresa:
            afectacionesCovidPersonalDesempennoEmpresa,
        afectacionesCovidSobreVentas: afectacionesCovidSobreVentas,
        codigoCIUUActividadPrimaria: codigoCIIUActividadPrimaria,
        codigoCIUUActividadComplementaria: codigoCIIUActividadComplementaria,
        observacionesPatentes: observacionesPatentes,
        imagenDocumentoLegal: imagenDocumentoLegal!,
      );
      try {
        switch (casoEncontrado) {
          case 1:
            await newPropiedad.insertInDB();
          case 2:
            bool? accepted = await showAcceptDismissAlertDialog(
              context,
              message:
                  "Se va a sobrescribir una propiedad ya existente. ¿Desea continuar?",
            );
            if (accepted == null || !accepted) return;
            await propiedadEnElNuevoLugar!.deleteInDB();
            await newPropiedad.insertInDB();
          case 3:
            bool? accepted = await showAcceptDismissAlertDialog(
              context,
              message:
                  "Se cambiará el numero de local de la propiedad actual. ¿Desea continuar?",
            );
            if (accepted == null || !accepted) return;
            newPropiedad.updateInDB(
              where: "id_predio = ? and no_edificio = ? and no_local = ?",
              whereArgs: [
                formGlobalStatus["idPredio"],
                formGlobalStatus["noEdificio"],
                formGlobalStatus["noLocal"],
              ],
            );
          case 4:
            bool? accepted = await showAcceptDismissAlertDialog(
              context,
              message:
                  "Se va a sobrescribir una propiedad ya existente. ¿Desea continuar?",
            );
            if (accepted == null || !accepted) return;
            await propiedadEnElNuevoLugar!.deleteInDB();
            newPropiedad.updateInDB(
              where: "id_predio = ? and no_edificio = ? and no_local = ?",
              whereArgs: [
                formGlobalStatus["idPredio"],
                formGlobalStatus["noEdificio"],
                formGlobalStatus["noLocal"],
              ],
            );
          case 5:
            bool? accepted = await showAcceptDismissAlertDialog(
              context,
              message:
                  "Se modificarán los datos de esta propiedad. ¿Desea continuar?",
            );
            if (accepted == null || !accepted) return;
            newPropiedad.updateInDB();
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

      formGlobalStatus["noLocal"] = null;
    }
  }

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++      +++++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++          +++++++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++   Utiles   ++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++          +++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++      +++++++++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  void agregarPropiedad() {
    formGlobalStatus["noLocal"] = null;
  }

  void editarPropiedad(int idx) {
    // _imageVersion++;
    formGlobalStatus["noLocal"] = propiedadesDelEdificio[idx].noLocal;
  }

  void eliminarPropiedad(BuildContext context, int idx) async {
    var currentPropiedad = propiedadesDelEdificio[idx];
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
            Text('Propiedad eliminada'),
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
    await currentPropiedad.deleteInDB();
    if (iWasNotOverriden) {
      snackbaractions = null;
      if (formGlobalStatus["noLocal"] == propiedadesDelEdificio[idx].noLocal) {
        formGlobalStatus["noLocal"] = null;
      } else {
        formGlobalStatus["noLocal"] = formGlobalStatus["noLocal"];
      }
    }
  }
}
