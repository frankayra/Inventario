import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:inventario/presentation/Screens/Form%20sections/Widgets/image_selection.dart';
import 'package:inventario/presentation/Screens/Form%20sections/Widgets/dialogs.dart';
import 'package:inventario/presentation/Screens/Form%20sections/Widgets/animations/countdown_circle.dart';
import 'package:inventario/presentation/Screens/Form%20sections/Widgets/utiles/db_general_management.dart'
    as db;
import 'package:inventario/presentation/Screens/Form%20sections/Widgets/utiles/wrappers.dart';
import 'package:inventario/presentation/Screens/Form%20sections/Widgets/utiles/hash.dart';
// import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class EdificioForm extends StatefulWidget {
  final FormGlobalStatusWrapper<int> formGlobalStatus;

  const EdificioForm({super.key, required this.formGlobalStatus});

  @override
  State<EdificioForm> createState() => EdificioFormState();
}

class EdificioFormState extends State<EdificioForm> {
  List<db.Edificio> edificiosDelPredio = [];
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? snackbaractions;
  bool overridingDelete = false;
  final _formKey = GlobalKey<FormState>();
  final _dropdownOptions = {
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
  @override
  void initState() {
    super.initState();
    if (widget.formGlobalStatus["idPredio"] != null) {
      idPredio = widget.formGlobalStatus["idPredio"];
      db.getAllEdificios(idPredio: widget.formGlobalStatus["idPredio"]).then((
        List<db.Edificio> edificios,
      ) {
        setState(() {
          edificiosDelPredio = edificios;
        });
        if (widget.formGlobalStatus["noEdificio"] != null) {
          db
              .getEdificio(
                idPredio: idPredio!,
                noEdificio: widget.formGlobalStatus["noEdificio"]!,
              )
              .then((currentEdificio) {
                if (currentEdificio != null) {
                  setState(() {
                    noEdificio = widget.formGlobalStatus["noEdificio"];
                    _distrito = currentEdificio.distrito;
                    _cantidadPisos = currentEdificio.cantidadPisos;
                    _cantidadSotanos = currentEdificio.cantidadSotanos;
                    _antejardin = currentEdificio.antejardin;
                    _materialFachada = currentEdificio.materialFachada;
                    _canoasBajantes = currentEdificio.canoasBajantes;
                    _observacionesEdificacion =
                        currentEdificio.observacionesEdificacion;
                    _estadoInmueble = currentEdificio.estadoInmueble;
                    _imagenConstruccion = currentEdificio.imagenConstruccion;
                    _observacionesConstruccion =
                        currentEdificio.observacionesConstruccion;
                    _cantidadMedidores = currentEdificio.cantidadMedidores;
                    _observacionesMedidores =
                        currentEdificio.observacionesMedidores;
                  });
                }
              });
        }
      });
    }
  }
  // DONE: Eliminar del diccionario el edificio que cambie de predio.
  // DONE: Marcar como activo(en edicion) el edificio que me mandaron si es que me mandaron.
  // DONE: Rellenar los campos de edificio si es que me mandaron un edificio.
  // DONE: Al guardar un formulario, resetearlo hacia abajo por ende vaciar los campos
  // DONE: Ver razon por la que cuando se rellena uno o varios campos de un subformulario, luego se despliega otro y se vuelve a desplegar el primero, no tiene nada rellenado.
  // TODO: ver el tema de los edificios que se transfieren a predios inexistentes en la base de datos.
  // TODO: Cuando se termina de agregar un edificio y se quedan los datos rellenados, estos deberian NO DESAPARECER automaticamente, sino cuando se aprieta el boton "+"
  // TODO: Al Darle al boton "+", si el formulario tiene algun cambio, preguntar si se quieren perder los cambios hechos. Yo siempre preguntaria, aunque no hubiese cambios.
  // DONE: Analizar el caso en que se este editando el noEdificio de un edificio que ya existia.

  // ++++++++++++++++++ Módulo Edificación ++++++++++++++++++ //
  bool changePredio = false;
  int? idPredio;
  int? noEdificio;
  int? _distrito;
  int? _cantidadPisos;
  int? _cantidadSotanos;
  int? _antejardin;
  int? _materialFachada;
  int? _canoasBajantes;
  String? _observacionesEdificacion;

  // ++++++++++++++++++ Módulo Construcción ++++++++++++++++++ //
  int? _estadoInmueble;
  Uint8List? _imagenConstruccion;
  // int _imageVersion = Random().nextInt(2000000);
  String? _observacionesConstruccion;

  // ++++++++++++++ Módulo Medidores Eléctricos ++++++++++++++ //
  int? _cantidadMedidores;
  String? _observacionesMedidores;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              key: ValueKey(edificiosDelPredio),
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _agregarEdificio,
                  child: Icon(Icons.add_circle_outlined),
                ),

                ...(edificiosDelPredio.asMap().entries.map((entry) {
                  var chipBackgroundColor = Colors.grey[100];
                  if (widget.formGlobalStatus["noEdificio"] != null &&
                      widget.formGlobalStatus["noEdificio"] ==
                          entry.value.noEdificio) {
                    chipBackgroundColor = Colors.green[100];
                  }
                  final idx = entry.key;
                  return InputChip(
                    label: Text('Ed. ${entry.value.noEdificio}'),
                    backgroundColor: chipBackgroundColor,
                    onDeleted: () => _eliminarEdificio(context, idx),
                    deleteIcon: Icon(Icons.close),
                    onPressed: () => _editarEdificio(idx),
                  );
                }).toList()),
              ],
            ),
            SizedBox(height: 40),
            if (widget.formGlobalStatus["noEdificio"] != null)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue:
                          widget.formGlobalStatus["idPredio"].toString(),
                      decoration: InputDecoration(labelText: 'Localización'),
                      enabled: changePredio,
                      validator: (value) {
                        final number = int.tryParse(value!);
                        if (number == null ||
                            number < 1000000000 ||
                            number >= 10000000000) {
                          return "Ingresa una Localización válida";
                        }
                        idPredio = number;
                      },
                    ),
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      Checkbox(
                        value: changePredio,
                        onChanged: (bool? newValue) {
                          setState(() {
                            changePredio = newValue!;
                          });
                        },
                        // activeColor: Colors.blue,
                        // checkColor: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
            // +++++++++++++++++++++++++++            +++++++++++++++++++++++++++ //
            // +++++++++++++++++++++++++                +++++++++++++++++++++++++ //
            // ++++++++++++++++++++++++    Edificación   ++++++++++++++++++++++++ //
            // +++++++++++++++++++++++++                +++++++++++++++++++++++++ //
            // +++++++++++++++++++++++++++            +++++++++++++++++++++++++++ //
            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
            // MyNumericInput(label: "Edificio", noValidValidationMessage: "Por favor ingresa el número de edificio"),
            TextFormField(
              // controller: _noEdificioController,
              key: ValueKey('noEdificio-$noEdificio'),
              initialValue: noEdificio?.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Edificio'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el número de edificio';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                noEdificio = number;
                return null;
              },
            ),
            DropdownButtonFormField(
              value: _distrito,
              items: _dropdownOptions["distrito"]!.entries
                  .map((distrito) {
                    return DropdownMenuItem(
                      value: distrito.key,
                      child: Text(distrito.value),
                    );
                  })
                  .toList(growable: false),
              onChanged: (value) {
                setState(() {
                  _distrito = value;
                });
              },
              decoration: InputDecoration(labelText: 'Distrito'),
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona un distrito';
                }
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("cantidadPisos-$_cantidadPisos"),
              initialValue:
                  _cantidadPisos != null ? _cantidadPisos.toString() : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Cantidad pisos'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la cantidad de pisos';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                _cantidadPisos = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("cantidadSotanos-$_cantidadSotanos"),
              initialValue:
                  _cantidadSotanos != null ? _cantidadSotanos.toString() : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Cantidad sótanos'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la cantidad de sótanos';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                _cantidadSotanos = number;
                return null;
              },
            ),
            DropdownButtonFormField(
              value: _antejardin,
              items:
                  _dropdownOptions["antejardin"]!.entries.map((option) {
                    return DropdownMenuItem(
                      value: option.key,
                      child: Text(option.value),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _antejardin = value;
                });
              },
              decoration: InputDecoration(labelText: 'Antejardín'),
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona una opción';
                }
                return null;
              },
            ),
            DropdownButtonFormField(
              value: _materialFachada,
              items:
                  _dropdownOptions["material fachada"]!.entries.map((option) {
                    return DropdownMenuItem(
                      value: option.key,
                      child: Text(option.value),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _materialFachada = value;
                });
              },
              decoration: InputDecoration(labelText: 'Material fachada'),
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona una opción';
                }
                return null;
              },
            ),
            DropdownButtonFormField(
              value: _canoasBajantes,
              items:
                  _dropdownOptions["canoas bajantes"]!.entries.map((option) {
                    return DropdownMenuItem(
                      value: option.key,
                      child: Text(option.value),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _canoasBajantes = value;
                });
              },
              decoration: InputDecoration(labelText: 'Canoas bajantes'),
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona una opción';
                }
                return null;
              },
            ),
            TextFormField(
              key: ValueKey(
                "observacionesEdificacion-$_observacionesEdificacion",
              ),
              initialValue:
                  _observacionesEdificacion != null
                      ? _observacionesEdificacion.toString()
                      : "",
              decoration: InputDecoration(
                labelText: 'Observaciones edificacion',
              ),
              onChanged: (value) {
                _observacionesEdificacion = value;
              },
            ),

            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
            // +++++++++++++++++++++++++++            +++++++++++++++++++++++++++ //
            // +++++++++++++++++++++++++                +++++++++++++++++++++++++ //
            // ++++++++++++++++++++++++   Construcción   ++++++++++++++++++++++++ //
            // +++++++++++++++++++++++++                +++++++++++++++++++++++++ //
            // +++++++++++++++++++++++++++            +++++++++++++++++++++++++++ //
            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
            DropdownButtonFormField(
              value: _estadoInmueble,
              items:
                  _dropdownOptions["estado inmueble"]!.entries.map((option) {
                    return DropdownMenuItem(
                      value: option.key,
                      child: Text(option.value),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _estadoInmueble = value;
                });
              },
              decoration: InputDecoration(labelText: 'Estado del inmueble'),
              validator: (value) {
                if (value == null) {
                  return 'Selecciona una opción';
                }
                return null;
              },
            ),
            MyImagePicker(
              key: ValueKey(
                "imagenConstruccion-${shortHash(_imagenConstruccion ?? Uint8List(1))}",
              ),
              label: "Imagen de construcción",
              initialValue: _imagenConstruccion,
              context: context,
              validator: (imagebytes) {
                if (imagebytes == null) return "Selecciona una imagen";
                _imagenConstruccion = imagebytes;
                return null;
              },
              onChanged: (imageBytes) {
                // setState(() {
                //   _imageVersion++;
                // });
              },
            ),
            TextFormField(
              key: ValueKey(
                "observacionesConstruccion-$_observacionesConstruccion",
              ),
              initialValue:
                  _observacionesConstruccion != null
                      ? _observacionesConstruccion.toString()
                      : "",
              decoration: InputDecoration(
                labelText: 'Observaciones Construcción',
              ),
              onChanged: (value) {
                _observacionesConstruccion = value;
              },
            ),

            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
            // +++++++++++++++++++++++++++            +++++++++++++++++++++++++++ //
            // +++++++++++++++++++++++++                +++++++++++++++++++++++++ //
            // ++++++++++++++++++++++++     Medidores    ++++++++++++++++++++++++ //
            // +++++++++++++++++++++++++                +++++++++++++++++++++++++ //
            // +++++++++++++++++++++++++++            +++++++++++++++++++++++++++ //
            // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
            TextFormField(
              key: ValueKey("cantidadMedidores-$_cantidadMedidores"),
              initialValue:
                  _cantidadMedidores != null
                      ? _cantidadMedidores.toString()
                      : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Cantidad Medidores'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la cantidad de medidores';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                _cantidadMedidores = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("observacionesMedidores-$_observacionesMedidores"),
              initialValue:
                  _observacionesMedidores != null
                      ? _observacionesMedidores.toString()
                      : "",
              decoration: InputDecoration(labelText: 'Observaciones Medidores'),
              onChanged: (value) {
                _observacionesMedidores = value;
              },
            ),

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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    db.Edificio? edificioEnElNuevoLugar = await db.getEdificio(
                      idPredio: idPredio!,
                      noEdificio: noEdificio!,
                    );
                    db.Predio? newPredio = await db.getPredio(
                      idPredio: idPredio!,
                    );

                    ///\  /\  /\  /\  /\  /\  /\  /\  /\
                    ///\\//\\//\\//\\//\\//\\//\\//\\//\\
                    //  \/  \/  \/  \/  \/  \/  \/  \/  \\
                    bool nuevoIngreso =
                        widget.formGlobalStatus['noEdificio'] == null;
                    bool edicion = !nuevoIngreso;
                    bool nadieEnElNuevoLugar = edificioEnElNuevoLugar == null;
                    bool alguienEnElNuevoLugar = !nadieEnElNuevoLugar;
                    bool mismoPredioDestino =
                        widget.formGlobalStatus["idPredio"] == idPredio;
                    bool mismoNoEdificioDestino =
                        widget.formGlobalStatus["noEdificio"] == noEdificio;
                    bool noExisteElNuevoPredio = newPredio == null;
                    bool mismoLugarDeDestino =
                        mismoPredioDestino && mismoNoEdificioDestino;
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
                      distrito: _distrito!,
                      cantidadPisos: _cantidadPisos!,
                      cantidadSotanos: _cantidadSotanos!,
                      antejardin: _antejardin!,
                      materialFachada: _materialFachada!,
                      canoasBajantes: _canoasBajantes!,
                      observacionesEdificacion: _observacionesEdificacion,
                      estadoInmueble: _estadoInmueble!,
                      imagenConstruccion: _imagenConstruccion!,
                      observacionesConstruccion: _observacionesConstruccion,
                      cantidadMedidores: _cantidadMedidores!,
                      observacionesMedidores: _observacionesMedidores,
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
                              widget.formGlobalStatus["idPredio"],
                              widget.formGlobalStatus["noEdificio"],
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
                              widget.formGlobalStatus["idPredio"],
                              widget.formGlobalStatus["noEdificio"],
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('✅ Datos guardados')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Error al guardar los datos')),
                      );
                    }

                    widget.formGlobalStatus["noEdificio"] = null;
                    // if (casoEncontrado != 5) {
                    //   return;
                    // }
                    // db
                    //     .getAllEdificios(
                    //       idPredio: widget.formGlobalStatus["idPredio"],
                    //     )
                    //     .then((List<db.Edificio> edificios) {
                    //       setState(() {
                    //         edificiosDelPredio = edificios;
                    //       });
                    //     });
                  }
                },
                child: Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++      +++++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++          +++++++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++   Utiles   ++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++          +++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++      +++++++++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  void _agregarEdificio() {
    widget.formGlobalStatus["noEdificio"] = null;
  }

  void _editarEdificio(int idx) {
    // _imageVersion++;
    widget.formGlobalStatus["noEdificio"] = edificiosDelPredio[idx].noEdificio;
  }

  void _eliminarEdificio(BuildContext context, int idx) async {
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
      if (widget.formGlobalStatus["noEdificio"] ==
          edificiosDelPredio[idx].noEdificio) {
        widget.formGlobalStatus["noEdificio"] = null;
      } else {
        widget.formGlobalStatus["noEdificio"] =
            widget.formGlobalStatus["noEdificio"];
      }
    }
  }
}
