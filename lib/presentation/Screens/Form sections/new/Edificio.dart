import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/presentation/Widgets/text.dart';
import 'package:inventario/presentation/Widgets/image_selection.dart';
import 'package:inventario/presentation/Widgets/selection.dart';
import 'package:inventario/presentation/Widgets/numeric.dart';
import 'package:inventario/presentation/Widgets/dialogs.dart';
import 'package:sqflite/sqflite.dart';
import 'package:inventario/utiles/db_general_management.dart' as db;
import 'package:inventario/utiles/wrappers.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EdificioForm extends StatefulWidget {
  final FormGlobalStatusWrapper<int> formGlobalStatus;

  const EdificioForm({super.key, required this.formGlobalStatus});

  @override
  State<EdificioForm> createState() => EdificioFormState();
}

class EdificioFormState extends State<EdificioForm> {
  List<db.Edificio> edificiosDelPredio = [];
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
      db.getAllEdificios(idPredio: widget.formGlobalStatus["idPredio"]).then((
        List<db.Edificio> edificios,
      ) {
        setState(() {
          edificiosDelPredio = edificios;
        });
      });
    }
  }
  // TODO: Eliminar del diccionario el edificio que cambie de predio.
  // TODO: Marcar como activo(en edicion) el edificio que me mandaron si es que me mandaron.
  // TODO: Rellenar los campos de edificio si es que me mandaron un edificio.
  // TODO: Al guardar un formulario, resetearlo hacia abajo por ende vaciar los campos
  // TODO: Ver razon por la que cuando se rellena uno o varios campos de un subformulario, luego se despliega otro y se vuelve a desplegar el primero, no tiene nada rellenado.
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
  final MyImagePickerInput _imagenConstruccion = MyImagePickerInput(
    imageLabel: "Imagen de construcción",
  );
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
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _agregarEdificio,
                  child: Icon(Icons.add_circle_outlined),
                ),

                ...(edificiosDelPredio.asMap().entries.map((entry) {
                  final idx = entry.key;
                  return InputChip(
                    label: Text('Ed. ${entry.value.noEdificio + 1}'),
                    backgroundColor: Colors.green[100],
                    onDeleted:
                        () => setState(() => edificiosDelPredio.removeAt(idx)),
                    deleteIcon: Icon(Icons.close),
                    onPressed: () => _editarEdificio(idx),
                  );
                }).toList()),
              ],
            ),
            SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue:
                        widget.formGlobalStatus.variables["idPredio"]
                            .toString(),
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
              decoration: InputDecoration(
                labelText: 'Observaciones edificaciones',
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
                  return 'Por favor selecciona una opción';
                }
                return null;
              },
            ),
            _imagenConstruccion,
            TextFormField(
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
                    bool? saveDecision;
                    bool overriting = false;
                    bool differentPredio =
                        idPredio != widget.formGlobalStatus["idPredio"];
                    bool differentNoEdificio =
                        noEdificio != widget.formGlobalStatus["noEdificio"];

                    final edificio = await db.getEdificio(
                      idPredio: idPredio!,
                      noEdificio: noEdificio!,
                    );

                    if (edificio != null) {
                      overriting = true;
                      saveDecision = await showAcceptDismissAlertDialog(
                        context,
                        message:
                            "Vas a sobrescribir un edificio ya existente. ¿Desea continuar?",
                      );
                    }
                    if (saveDecision == null) {
                      if (overriting) {
                        // ---- Caso 1: saveDecision es null porque se entro en el AlertDialog y se cerro por clickear fuera del area del mismo.
                        return;
                      }
                      // ---- Caso 2: saveDecision es null porque asi se asigno en un principio y nunca se entro al if que comprueba si hay sobrescritura.
                    } else {
                      if (!saveDecision) {
                        // ---- Caso 3: saveDecision es false porque se rechazo sobrescribir los datos del edificio ya existente. Esto se aplica tanto para edificios del mismo predio como para el caso que se quiere sobrescribir uno de un predio diferente
                        return;
                      } else {
                        // ---- Caso 4: saveDecesion es true y por tanto se deberia comprobar si estamos editando informacion de la misma tupla(mismas llaves) o si cambia de llaves y hay que actualizar la tupla
                        if (differentPredio || differentNoEdificio) {
                          // ---- Caso 4.1: Se esta aobrescribiendo un edificio diferente. Aqui siempre tendremos que override es true ya que saveDecision es != null
                          edificio!.deleteInDB();
                        } else {
                          // ---- Caso 4.2: Se esta editando el propio edificio. overriding es true
                        }
                      }
                    }
                    // Casos que pasan hacia aqui: Caso 2, Caso 4.1, Caso 4.2. Esto significa que aqui obtenemos los casos:
                    // 1. Hay que insertar sin mas porque no existia la tupla aun en la BD.
                    // 2. Ya se elimino la tupla que estaba ahi y se puede insertar, pero deberia actualizar los datos de la tupla anterior para que se transfieran las propiedades junto al edificio
                    // 3. Hay que modificar la tupla actual
                    //     3.1. sus propiedades
                    //     3.2. sus propiedades y llaves primarias

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
                      imagenConstruccion:
                          await _imagenConstruccion.getImageBytes,
                      observacionesConstruccion: _observacionesConstruccion,
                      cantidadMedidores: _cantidadMedidores!,
                      observacionesMedidores: _observacionesMedidores,
                    );
                    try {
                      if (overriting) {
                        // Caso 2 y 3
                        print("Caso 2 o 3");
                        await newEdificio.updateInDB(
                          where: "id_predio = ? AND no_edificio = ?",
                          whereArgs: [
                            widget.formGlobalStatus["idPredio"],
                            widget.formGlobalStatus["noEdificio"],
                          ],
                        );
                      } else {
                        // Caso 1
                        print("Caso 1");
                        await newEdificio.insertInDB();
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Error al guardar los datos')),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✅ Datos guardados')),
                    );
                    widget.formGlobalStatus["noEdificio"] = null;
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
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Nuevo registro'),
            content: Text('Formulario para nueva instancia'),
            // content: _PropiedadAux(),
            actions: [
              TextButton(
                onPressed: () async {
                  setState(
                    () async => edificiosDelPredio.add(
                      db.Edificio(
                        // Claves
                        idPredio: widget.formGlobalStatus["idPredio"],
                        noEdificio: widget.formGlobalStatus["noEdificio"],
                        // noEdificio: noEdificio!,
                        distrito: _distrito!,
                        cantidadPisos: _cantidadPisos!,
                        cantidadSotanos: _cantidadSotanos!,
                        antejardin: _antejardin!,
                        materialFachada: _materialFachada!,
                        canoasBajantes: _canoasBajantes!,
                        observacionesEdificacion: _observacionesEdificacion,
                        estadoInmueble: _estadoInmueble!,
                        imagenConstruccion:
                            await _imagenConstruccion.getImageBytes,
                        observacionesConstruccion: _observacionesConstruccion,
                        cantidadMedidores: _cantidadMedidores!,
                        observacionesMedidores: _observacionesMedidores,
                      ),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void _editarEdificio(int idx) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Editar instancia ${idx + 1}'),
            content: Text('Formulario de edición'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cerrar'),
              ),
            ],
          ),
    );
  }
}
