import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:inventario/View/Widgets/date_selection.dart';
import 'package:inventario/View/Widgets/image_selection.dart';
import 'package:inventario/ModelView/wrappers.dart';
import 'package:inventario/ModelView/hash.dart';
import 'package:inventario/View/Widgets/countdown_circle.dart';
import 'package:inventario/ModelView/PropiedadFormController.dart';

class PropiedadForm extends StatefulWidget {
  final FormGlobalStatusWrapper<int> formGlobalStatus;
  const PropiedadForm({super.key, required this.formGlobalStatus});

  @override
  State<PropiedadForm> createState() => PropiedadFormState();
}

class PropiedadFormState extends State<PropiedadForm> {
  final _formKey = GlobalKey<FormState>();
  late PropiedadFormController controller;

  @override
  void initState() {
    super.initState();
    controller = PropiedadFormController(
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
          children: [
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: controller.agregarPropiedad,
                  child: Icon(Icons.add_circle_outlined),
                ),

                ...(controller.propiedadesDelEdificio.asMap().entries.map((
                  entry,
                ) {
                  var chipBackgroundColor = Colors.grey[100];
                  if (widget.formGlobalStatus["noEdificio"] != null &&
                      widget.formGlobalStatus["noLocal"] != null &&
                      widget.formGlobalStatus["noLocal"] ==
                          entry.value.noLocal) {
                    chipBackgroundColor = Colors.green[100];
                  }
                  final idx = entry.key;
                  return InputChip(
                    label: Text('P. ${entry.value.noLocal}'),
                    backgroundColor: chipBackgroundColor,
                    onDeleted: () => controller.eliminarPropiedad(context, idx),
                    deleteIcon: Icon(Icons.close),
                    onPressed: () => controller.editarPropiedad(idx),
                  );
                }).toList()),
              ],
            ),
            SizedBox(height: 40),
            TextFormField(
              key: ValueKey("noLocal-${controller.noLocal}"),
              initialValue:
                  controller.noLocal != null
                      ? controller.noLocal.toString()
                      : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Numero Local'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el número de local';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                controller.noLocal = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("nivelPiso-${controller.nivelPiso}"),
              initialValue:
                  controller.nivelPiso != null
                      ? controller.nivelPiso.toString()
                      : "",
              decoration: InputDecoration(labelText: 'Nivel piso'),
              onChanged: (value) {
                controller.nivelPiso = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa el campo Nivel Piso';
                }
                return null;
              },
            ),
            TextFormField(
              key: ValueKey(
                "actividadPrimaria-${controller.actividadPrimaria}",
              ),
              initialValue:
                  controller.actividadPrimaria != null
                      ? controller.actividadPrimaria.toString()
                      : "",
              decoration: InputDecoration(labelText: 'Actividad primaria'),
              onChanged: (value) {
                controller.actividadPrimaria = value;
              },

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa la Actividad primaria';
                }
                return null;
              },
            ),
            TextFormField(
              key: ValueKey(
                "actividadComplementaria-${controller.actividadComplementaria}",
              ),
              initialValue:
                  controller.actividadComplementaria != null
                      ? controller.actividadComplementaria.toString()
                      : "",
              decoration: InputDecoration(
                labelText: 'Actividad complementaria',
              ),
              onChanged: (value) {
                controller.actividadComplementaria = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa la Actividad complementario';
                }
                return null;
              },
            ),
            DropdownButtonFormField(
              value: controller.estadoNegocio,
              items: controller.dropdownOptions["estadoNegocio"]!.entries
                  .map((estado) {
                    return DropdownMenuItem(
                      value: estado.key,
                      child: Text(estado.value),
                    );
                  })
                  .toList(growable: false),
              onChanged: (value) {
                setState(() {
                  controller.estadoNegocio = value;
                });
              },
              decoration: InputDecoration(labelText: 'Estado Negocio'),
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona un estado';
                }
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("nombreNegocio-${controller.nombreNegocio}"),
              initialValue:
                  controller.nombreNegocio != null
                      ? controller.nombreNegocio.toString()
                      : "",
              decoration: InputDecoration(labelText: 'Nombre negocio'),
              onChanged: (value) {
                controller.nombreNegocio = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa el nombre del negocio';
                }
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("cantidadParqueos-${controller.cantidadParqueos}"),
              initialValue:
                  controller.cantidadParqueos != null
                      ? controller.cantidadParqueos.toString()
                      : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Cantidad de parqueos'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la cantidad de parqueos';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                controller.cantidadParqueos = number;
                return null;
              },
            ),
            DropdownButtonFormField(
              value: controller.documentoMostrado,
              items: controller.dropdownOptions["documentoMostrado"]!.entries
                  .map((documento) {
                    return DropdownMenuItem(
                      value: documento.key,
                      child: Text(documento.value),
                    );
                  })
                  .toList(growable: false),
              onChanged: (value) {
                controller.documentoMostrado = value;
              },
              decoration: InputDecoration(labelText: 'Documento mostrado'),
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona una opción';
                }
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("nombrePatentado-${controller.nombrePatentado}"),
              initialValue:
                  controller.nombrePatentado != null
                      ? controller.nombrePatentado.toString()
                      : "",
              decoration: InputDecoration(labelText: 'Nombre del patentado'),
              onChanged: (value) {
                controller.nombrePatentado = value;
              },
              validator:
                  (value) =>
                      value != null && value.isNotEmpty
                          ? null
                          : "Ingrese el nombre del patentado",
            ),
            TextFormField(
              key: ValueKey(
                "numeroPatenteComercial-${controller.numeroPatenteComercial}",
              ),
              initialValue:
                  controller.numeroPatenteComercial != null
                      ? controller.numeroPatenteComercial.toString()
                      : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número de patente comercial',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el número de patente comercial';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                controller.numeroPatenteComercial = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("cedulaPatentado-${controller.cedulaPatentado}"),
              initialValue:
                  controller.cedulaPatentado != null
                      ? controller.cedulaPatentado.toString()
                      : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Cédula patentado'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la el número de cédula patentado';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                controller.cedulaPatentado = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey(
                "nombreActividadPatente-${controller.nombreActividadPatente}",
              ),
              initialValue:
                  controller.nombreActividadPatente != null
                      ? controller.nombreActividadPatente.toString()
                      : "",
              decoration: InputDecoration(
                labelText: 'Nombre de la actividad registrada en la patente',
              ),
              onChanged: (value) {
                controller.nombreActividadPatente = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa el nombre de la actividad registrada';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            CheckboxListTile(
              value: controller.tieneMasPatentes,
              title: Text("Tiene autorizadas más patentes"),
              onChanged: (bool? selected) {
                setState(() {
                  controller.tieneMasPatentes = selected!;
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
            TextFormField(
              enabled: controller.tieneMasPatentes,
              key: ValueKey("numeroPatente_2-${controller.numeroPatente_2}"),
              initialValue:
                  controller.numeroPatente_2 != null
                      ? controller.numeroPatente_2.toString()
                      : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Número de patente 2'),
              validator: (value) {
                if (controller.tieneMasPatentes) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el número de patente comercial 2';
                  }
                  final number = int.tryParse(value!);
                  if (number == null) {
                    return 'Por favor ingresa un número válido';
                  }
                  controller.numeroPatente_2 = number;
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            CheckboxListTile(
              value: controller.tienePermisoSalud,
              title: Text("Tiene permiso de salud"),
              onChanged: (bool? selected) {
                setState(() {
                  controller.tienePermisoSalud = selected!;
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
            TextFormField(
              enabled: controller.tienePermisoSalud,
              key: ValueKey(
                "numeroPermisoSalud-${controller.numeroPermisoSalud}",
              ),
              initialValue:
                  controller.numeroPermisoSalud != null
                      ? controller.numeroPermisoSalud.toString()
                      : "",
              decoration: InputDecoration(
                labelText: 'Número de permiso de salud',
              ),
              onChanged: (value) {
                controller.numeroPermisoSalud = value;
              },
              validator: (value) {
                if (controller.tienePermisoSalud &&
                    (value == null || value.isEmpty)) {
                  return 'Por favor ingresa el número de permiso de salud';
                }
                return null;
              },
            ),
            DateInput(
              key: ValueKey(
                'fechaVigenciaPermisoSalud-${controller.tienePermisoSalud}-${controller.fechaVigenciaPermisoSalud}',
              ),
              initialValue:
                  controller.fechaVigenciaPermisoSalud != null
                      ? controller.fechaVigenciaPermisoSalud.toString()
                      : "",
              firstDate: DateTime(2000, 1, 1),
              lastDate: DateTime(2100),
              labelText: 'Fecha de vigencia del permiso de salud (AAAA-MM-DD)',
              onChanged: (value) {
                controller.fechaVigenciaPermisoSalud = value;
              },
              validator: (value) {
                if (!controller.tienePermisoSalud) return null;
                if (value == null || value.isEmpty) {
                  return "Ingresa la fecha de vigencia del permiso de salud";
                }
              },
              enabled: () => controller.tienePermisoSalud,
              // enabled: controller.tienePermisoSalud,
            ),
            TextFormField(
              enabled: controller.tienePermisoSalud,
              key: ValueKey(
                "codigoCIIUPermisoSalud-${controller.codigoCIIUPermisoSalud}",
              ),
              initialValue:
                  controller.codigoCIIUPermisoSalud != null
                      ? controller.codigoCIIUPermisoSalud.toString()
                      : "",
              decoration: InputDecoration(
                labelText: 'Código CIIU del permiso de salud',
              ),
              onChanged: (value) {
                controller.codigoCIIUPermisoSalud = value;
              },
              validator: (value) {
                if (controller.tienePermisoSalud &&
                    (value == null || value.isEmpty)) {
                  return 'Por favor ingresa el código CIIU del permiso de salud';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            CheckboxListTile(
              value: controller.seTrataDeLocalMercado,
              title: Text("Se trata de un local de mercado"),
              onChanged: (bool? selected) {
                setState(() {
                  controller.seTrataDeLocalMercado = selected!;
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
            TextFormField(
              enabled: controller.seTrataDeLocalMercado,
              key: ValueKey(
                "numeroLocalMercado-${controller.numeroLocalMercado}",
              ),
              initialValue:
                  controller.numeroLocalMercado != null
                      ? controller.numeroLocalMercado.toString()
                      : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Número de local mercado'),
              validator: (value) {
                if (!controller.seTrataDeLocalMercado) return null;
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el número de local mercado';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                controller.numeroLocalMercado = number;
                return null;
              },
            ),
            SizedBox(height: 20),
            CheckboxListTile(
              value: controller.tienePatenteLicores,
              title: Text("Tiene patente de licores"),
              onChanged: (bool? selected) {
                setState(() {
                  controller.tienePatenteLicores = selected!;
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
            TextFormField(
              enabled: controller.tienePatenteLicores,
              key: ValueKey(
                "numeroPatenteLicores-${controller.numeroPatenteLicores}",
              ),
              initialValue:
                  controller.numeroPatenteLicores != null
                      ? controller.numeroPatenteLicores.toString()
                      : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número de patente licores',
              ),
              validator: (value) {
                if (!controller.tienePatenteLicores) return null;
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el número de patente licores';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                controller.numeroPatenteLicores = number;
                return null;
              },
            ),
            DropdownButtonFormField(
              value: controller.areaActividad,
              items: controller.dropdownOptions["areaActividad"]!.entries
                  .map((area) {
                    return DropdownMenuItem(
                      value: area.key,
                      child: Text(area.value),
                    );
                  })
                  .toList(growable: false),
              onChanged: (value) {
                setState(() {
                  controller.areaActividad = value;
                });
              },
              decoration: InputDecoration(labelText: 'Área de actividad'),
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona un área de actividad';
                }
                return null;
              },
            ),
            TextFormField(
              key: ValueKey(
                "telefonoPatentado-${controller.telefonoPatentado}",
              ),
              initialValue:
                  controller.telefonoPatentado != null
                      ? controller.telefonoPatentado.toString()
                      : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Teléfono patentado'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el teléfono del patentado';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                controller.telefonoPatentado = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey(
                "correoElectronico-${controller.correoElectronico}",
              ),
              initialValue:
                  controller.correoElectronico != null
                      ? controller.correoElectronico.toString()
                      : "",
              decoration: InputDecoration(labelText: 'Correo electrónico'),
              onChanged: (value) {
                controller.correoElectronico = value;
              },
              validator:
                  (value) =>
                      value != null && value.isNotEmpty
                          ? null
                          : "Ingrese el correo electronico",
            ),
            TextFormField(
              key: ValueKey(
                "cantidadEmpleadosAntesCovid-${controller.cantidadEmpleadosAntesCovid}",
              ),
              initialValue:
                  controller.cantidadEmpleadosAntesCovid != null
                      ? controller.cantidadEmpleadosAntesCovid.toString()
                      : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad de empleados antes del COVID-19',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la cantidad de empleados antes del COVID-19';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                controller.cantidadEmpleadosAntesCovid = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey(
                "cantidadEmpleadosActual-${controller.cantidadEmpleadosActual}",
              ),
              initialValue:
                  controller.cantidadEmpleadosActual != null
                      ? controller.cantidadEmpleadosActual.toString()
                      : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad de empleados actual',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la cantidad de empleados actual';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                controller.cantidadEmpleadosActual = number;
                return null;
              },
            ),
            SizedBox(height: 30),
            Text(
              'Afectaciones por COVID personal y desempeño de la empresa:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ListView(
              key: ValueKey(
                "afectacionesCovidPersonalDesempennoEmpresa-${controller.afectacionesCovidPersonalDesempennoEmpresa}",
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children:
                  controller
                      .dropdownOptions["afectacionesCovidPersonalDesempennoEmpresa"]!
                      .entries
                      .map((e) {
                        return CheckboxListTile(
                          value: controller
                              .afectacionesCovidPersonalDesempennoEmpresaList
                              .contains(e.key),
                          title: Text(e.value),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          onChanged: (bool? selected) {
                            if (selected == true) {
                              controller
                                  .afectacionesCovidPersonalDesempennoEmpresaList
                                  .add(e.key);
                            } else {
                              controller
                                  .afectacionesCovidPersonalDesempennoEmpresaList
                                  .remove(e.key);
                            }
                            setState(() {
                              controller
                                  .afectacionesCovidPersonalDesempennoEmpresa = controller
                                  .afectacionesCovidPersonalDesempennoEmpresaList
                                  .map((key) {
                                    return controller
                                        .dropdownOptions["afectacionesCovidPersonalDesempennoEmpresa"]![key]!;
                                  })
                                  .join(', ');
                            });
                          },
                        );
                      })
                      .toList(),
            ),

            SizedBox(height: 30),
            Text(
              'Afectaciones por COVID sobre las ventas:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ListView(
              key: ValueKey(
                "afectacionesCovidSobreVentas-${controller.afectacionesCovidSobreVentas}",
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children:
                  controller
                      .dropdownOptions["afectacionesCovidSobreVentas"]!
                      .entries
                      .map((e) {
                        return CheckboxListTile(
                          value: controller.afectacionesCovidSobreVentasList
                              .contains(e.key),
                          title: Text(e.value),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          onChanged: (bool? selected) {
                            if (selected == true) {
                              controller.afectacionesCovidSobreVentasList.add(
                                e.key,
                              );
                            } else {
                              controller.afectacionesCovidSobreVentasList
                                  .remove(e.key);
                            }
                            setState(() {
                              controller
                                  .afectacionesCovidSobreVentas = controller
                                  .afectacionesCovidSobreVentasList
                                  .map((key) {
                                    return controller
                                        .dropdownOptions["afectacionesCovidSobreVentas"]![key]!;
                                  })
                                  .join(', ');
                            });
                          },
                        );
                      })
                      .toList(),
            ),
            TextFormField(
              key: ValueKey(
                "codigoCIIUActividadPrimaria-${controller.codigoCIIUActividadPrimaria}",
              ),
              initialValue:
                  controller.codigoCIIUActividadPrimaria != null
                      ? controller.codigoCIIUActividadPrimaria.toString()
                      : "",
              decoration: InputDecoration(
                labelText: 'Código CIIU actividad primaria',
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  controller.codigoCIIUActividadPrimaria = value;
                  return null;
                }
                return "Ingrese el codigo CIIU de la actividad primaria";
              },
            ),
            TextFormField(
              key: ValueKey(
                "controller.codigoCIIUActividadComplementaria-${controller.codigoCIIUActividadComplementaria}",
              ),
              initialValue:
                  controller.codigoCIIUActividadComplementaria != null
                      ? controller.codigoCIIUActividadComplementaria.toString()
                      : "",
              decoration: InputDecoration(
                labelText: 'Código CIIU actividad complementaria',
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  controller.codigoCIIUActividadComplementaria = value;
                  return null;
                }
                return "Ingrese el codigo CIIU de la actividad complementaria";
              },
            ),
            TextFormField(
              key: ValueKey(
                "observacionesPatentes-${controller.observacionesPatentes}",
              ),
              initialValue:
                  controller.observacionesPatentes != null
                      ? controller.observacionesPatentes.toString()
                      : "",
              decoration: InputDecoration(labelText: 'Observaciones patentes'),
              onChanged: (value) {
                controller.observacionesPatentes = value;
              },
            ),
            SizedBox(height: 20),
            MyImagePicker(
              key: ValueKey(
                "imagenDocumentoLegal-${shortHash(controller.imagenDocumentoLegal ?? Uint8List(1))}",
              ),
              label: "Imagen de documento legal",
              initialValue: controller.imagenDocumentoLegal,
              context: context,
              validator: (imagebytes) {
                if (imagebytes == null) return "Selecciona una imagen";
                controller.imagenDocumentoLegal = imagebytes;
                return null;
              },
              onChanged: (imageBytes) {
                // setState(() {
                //   _imageVersion++;
                // });
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
