import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:inventario/presentation/Widgets/image_selection.dart';
import 'package:inventario/Model/wrappers.dart';
import 'package:inventario/Model/hash.dart';
import 'package:inventario/Controller/EdificioFormController.dart';
// import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class EdificioForm extends StatefulWidget {
  final FormGlobalStatusWrapper<int> formGlobalStatus;

  const EdificioForm({super.key, required this.formGlobalStatus});

  @override
  State<EdificioForm> createState() => EdificioFormState();
}

class EdificioFormState extends State<EdificioForm> {
  final _formKey = GlobalKey<FormState>();
  late EdificioFormController controller;
  @override
  void initState() {
    super.initState();
    controller = EdificioFormController(
      formKey: _formKey,
      formGlobalStatus: widget.formGlobalStatus,
      formSetStateCallbackFunction: () => setState(() {}),
    );
  }

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
              key: ValueKey(controller.edificiosDelPredio),
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: controller.agregarEdificio,
                  child: Icon(Icons.add_circle_outlined),
                ),

                ...(controller.edificiosDelPredio.asMap().entries.map((entry) {
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
                    onDeleted: () => controller.eliminarEdificio(context, idx),
                    deleteIcon: Icon(Icons.close),
                    onPressed: () => controller.editarEdificio(idx),
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
                      enabled: controller.changePredio,
                      validator: (value) {
                        final number = int.tryParse(value!);
                        if (number == null ||
                            number < 1000000000 ||
                            number >= 10000000000) {
                          return "Ingresa una Localización válida";
                        }
                        controller.idPredio = number;
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
                        value: controller.changePredio,
                        onChanged: (bool? newValue) {
                          setState(() {
                            controller.changePredio = newValue!;
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
              key: ValueKey('noEdificio-${controller.noEdificio}'),
              initialValue: controller.noEdificio?.toString(),
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
                controller.noEdificio = number;
                return null;
              },
            ),
            DropdownButtonFormField(
              value: controller.distrito,
              items: controller.dropdownOptions["distrito"]!.entries
                  .map((distrito) {
                    return DropdownMenuItem(
                      value: distrito.key,
                      child: Text(distrito.value),
                    );
                  })
                  .toList(growable: false),
              onChanged: (value) {
                setState(() {
                  controller.distrito = value;
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
              key: ValueKey("cantidadPisos-${controller.cantidadPisos}"),
              initialValue:
                  controller.cantidadPisos != null
                      ? controller.cantidadPisos.toString()
                      : "",
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
                controller.cantidadPisos = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("cantidadSotanos-${controller.cantidadSotanos}"),
              initialValue:
                  controller.cantidadSotanos != null
                      ? controller.cantidadSotanos.toString()
                      : "",
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
                controller.cantidadSotanos = number;
                return null;
              },
            ),
            DropdownButtonFormField(
              value: controller.antejardin,
              items:
                  controller.dropdownOptions["antejardin"]!.entries.map((
                    option,
                  ) {
                    return DropdownMenuItem(
                      value: option.key,
                      child: Text(option.value),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  controller.antejardin = value;
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
              value: controller.materialFachada,
              items:
                  controller.dropdownOptions["material fachada"]!.entries.map((
                    option,
                  ) {
                    return DropdownMenuItem(
                      value: option.key,
                      child: Text(option.value),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  controller.materialFachada = value;
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
              value: controller.canoasBajantes,
              items:
                  controller.dropdownOptions["canoas bajantes"]!.entries.map((
                    option,
                  ) {
                    return DropdownMenuItem(
                      value: option.key,
                      child: Text(option.value),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  controller.canoasBajantes = value;
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
                "observacionesEdificacion-${controller.observacionesEdificacion}",
              ),
              initialValue:
                  controller.observacionesEdificacion != null
                      ? controller.observacionesEdificacion.toString()
                      : "",
              decoration: InputDecoration(
                labelText: 'Observaciones edificacion',
              ),
              onChanged: (value) {
                controller.observacionesEdificacion = value;
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
              value: controller.estadoInmueble,
              items:
                  controller.dropdownOptions["estado inmueble"]!.entries.map((
                    option,
                  ) {
                    return DropdownMenuItem(
                      value: option.key,
                      child: Text(option.value),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  controller.estadoInmueble = value;
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
                "imagenConstruccion-${shortHash(controller.imagenConstruccion ?? Uint8List(1))}",
              ),
              label: "Imagen de construcción",
              initialValue: controller.imagenConstruccion,
              context: context,
              validator: (imagebytes) {
                if (imagebytes == null) return "Selecciona una imagen";
                controller.imagenConstruccion = imagebytes;
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
                "observacionesConstruccion-${controller.observacionesConstruccion}",
              ),
              initialValue:
                  controller.observacionesConstruccion != null
                      ? controller.observacionesConstruccion.toString()
                      : "",
              decoration: InputDecoration(
                labelText: 'Observaciones Construcción',
              ),
              onChanged: (value) {
                controller.observacionesConstruccion = value;
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
              key: ValueKey(
                "cantidadMedidores-${controller.cantidadMedidores}",
              ),
              initialValue:
                  controller.cantidadMedidores != null
                      ? controller.cantidadMedidores.toString()
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
                controller.cantidadMedidores = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey(
                "observacionesMedidores-${controller.observacionesMedidores}",
              ),
              initialValue:
                  controller.observacionesMedidores != null
                      ? controller.observacionesMedidores.toString()
                      : "",
              decoration: InputDecoration(labelText: 'Observaciones Medidores'),
              onChanged: (value) {
                controller.observacionesMedidores = value;
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async => controller.validateForm(context),
                child: Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
