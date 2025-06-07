import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventario/presentation/Widgets/date_selection.dart';
import 'package:inventario/presentation/Widgets/image_selection.dart';
import 'package:inventario/presentation/Widgets/dialogs.dart';
import 'package:inventario/utiles/db_general_management.dart' as db;
import 'package:inventario/utiles/wrappers.dart';
import 'package:inventario/utiles/hash.dart';

// TODO: Acabar de arreglar lo de los campos a la hora de la validacion
// TODO: Que se guarde bien una propiedad.
// TODO: Como sera que se agregan nuevas instancias y se cambian los valores automaticamente.

// TODO: arreglar los validadores de los campos opcionales que se activan con los campos check.
// TODO: Arreglar el widget de fecha.
// TODO: Verificar la correcta funcion al presionar en una propiedad.

class PropiedadForm extends StatefulWidget {
  final FormGlobalStatusWrapper<int> formGlobalStatus;
  const PropiedadForm({super.key, required this.formGlobalStatus});

  @override
  State<PropiedadForm> createState() => PropiedadFormState();
}

class PropiedadFormState extends State<PropiedadForm> {
  List<db.Propiedad> propiedadesDelEdificio = [];
  final _formKey = GlobalKey<FormState>();
  final _dropdownOptions = {
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
    },
    "afectacionesCovidSobreVentas": {
      1: 'Ingresó "0" ante la afectación de una orden sanitaria',
      2: 'Reducción de los ingresos entre un 50-90%',
      3: 'Reducción de los ingresos entre un 20-50%',
      4: 'Se mantuvieron dentro de lo esperado',
      5: 'Aumentaron',
      6: 'Ninguna',
      7: 'NS-NR',
    },
  };
  @override
  void initState() {
    super.initState();
    if (widget.formGlobalStatus["idPredio"] != null &&
        widget.formGlobalStatus["noEdificio"] != null) {
      idPredio = widget.formGlobalStatus["idPredio"];
      noEdificio = widget.formGlobalStatus["noEdificio"];
      db
          .getAllPropiedades(
            idPredio: widget.formGlobalStatus["idPredio"],
            noEdificio: widget.formGlobalStatus["noEdificio"],
          )
          .then((List<db.Propiedad> propiedades) {
            setState(() {
              propiedadesDelEdificio = propiedades;
            });
            if (widget.formGlobalStatus["noLocal"] != null) {
              db
                  .getPropiedad(
                    idPredio: idPredio!,
                    noEdificio: noEdificio!,
                    noLocal: widget.formGlobalStatus["noLocal"]!,
                  )
                  .then((currentPropiedad) {
                    if (currentPropiedad != null) {
                      setState(() {
                        noLocal = widget.formGlobalStatus["noLocal"];
                        _nivelPiso = currentPropiedad.nivelPiso;
                        _actividadPrimaria = currentPropiedad.actividadPrimaria;
                        _actividadComplementaria =
                            currentPropiedad.actividadComplementaria;
                        _estadoNegocio = currentPropiedad.estadoNegocio;
                        _nombreNegocio = currentPropiedad.nombreNegocio;
                        _cantidadParqueos = currentPropiedad.cantidadParqueos;
                        _documentoMostrado = currentPropiedad.documentoMostrado;
                        _nombrePatentado = currentPropiedad.nombrePatentado;
                        _numeroPatenteComercial =
                            currentPropiedad.numeroPatenteComercial;
                        _cedulaPatentado = currentPropiedad.cedulaPatentado;
                        _nombreActividadPatente =
                            currentPropiedad.nombreActividadPatente;
                        _tieneMasPatentes = currentPropiedad.tieneMasPatentes;
                        _numeroPatente_2 = currentPropiedad.numeroPatente_2;
                        _tienePermisoSalud = currentPropiedad.tienePermisoSalud;
                        _numeroPermisoSalud =
                            currentPropiedad.numeroPermisoSalud;
                        _fechaVigenciaPermisoSalud =
                            currentPropiedad.fechaVigenciaPermisoSalud;
                        _codigoCIIUPermisoSalud =
                            currentPropiedad.codigoCIIUPermisoSalud;
                        _seTrataDeLocalMercado =
                            currentPropiedad.seTrataDeLocalMercado;
                        _numeroLocalMercado =
                            currentPropiedad.numeroLocalMercado;
                        _tienePatenteLicores =
                            currentPropiedad.tienePatenteLicores;
                        _numeroPatenteLicores =
                            currentPropiedad.numeroPatenteLicores;
                        _areaActividad = currentPropiedad!.areaActividad;
                        _telefonoPatentado = currentPropiedad.telefonoPatentado;
                        _correoElectronico = currentPropiedad.correoElectronico;
                        _cantidadEmpleadosAntesCovid =
                            currentPropiedad.cantidadEmpleadosAntesCovid;
                        _cantidadEmpleadosActual =
                            currentPropiedad.cantidadEmpleadosActual;
                        _afectacionesCovidPersonalDesempennoEmpresa =
                            currentPropiedad
                                .afectacionesCovidPersonalDesempennoEmpresa;
                        _afectacionesCovidSobreVentas =
                            currentPropiedad.afectacionesCovidSobreVentas;
                        _codigoCIIUActividadPrimaria =
                            currentPropiedad.codigoCIUUActividadPrimaria;
                        _codigoCIIUActividadComplementaria =
                            currentPropiedad.codigoCIUUActividadComplementaria;
                        _observacionesPatentes =
                            currentPropiedad.observacionesPatentes;
                        _imagenDocumentoLegal =
                            currentPropiedad.imagenDocumentoLegal;

                        if (_afectacionesCovidPersonalDesempennoEmpresa !=
                            null) {
                          _afectacionesCovidPersonalDesempennoEmpresaList =
                              _afectacionesCovidPersonalDesempennoEmpresa!
                                  .split(",")
                                  .map((item) => int.parse(item))
                                  .toList();
                        }
                        if (_afectacionesCovidSobreVentas != null) {
                          _afectacionesCovidSobreVentasList =
                              _afectacionesCovidSobreVentas!
                                  .split(",")
                                  .map((item) => int.parse(item))
                                  .toList();
                        }
                      });
                    }
                  });
            }
          });
    }
  }

  // ++++++ Módulo Uso de suelo y Patentes Comerciales ++++++ //
  bool changeEdificio = false;
  int? idPredio;
  int? noEdificio;
  int? noLocal;
  String? _nivelPiso;
  String? _actividadPrimaria;
  String? _actividadComplementaria;
  int? _estadoNegocio;
  String? _nombreNegocio;
  int? _cantidadParqueos;
  int? _documentoMostrado;
  String? _nombrePatentado;
  int? _numeroPatenteComercial;
  int? _cedulaPatentado;
  String? _nombreActividadPatente;
  bool _tieneMasPatentes = false;
  int? _numeroPatente_2;
  bool _tienePermisoSalud = false;
  String? _numeroPermisoSalud;
  int? _fechaVigenciaPermisoSalud;
  String? _codigoCIIUPermisoSalud;
  bool _seTrataDeLocalMercado = false;
  int? _numeroLocalMercado;
  bool _tienePatenteLicores = false;
  int? _numeroPatenteLicores;
  int? _areaActividad;
  int? _telefonoPatentado;
  String? _correoElectronico;
  int? _cantidadEmpleadosAntesCovid;
  int? _cantidadEmpleadosActual;
  String? _afectacionesCovidPersonalDesempennoEmpresa;
  String? _afectacionesCovidSobreVentas;
  List<int> _afectacionesCovidPersonalDesempennoEmpresaList = [];
  List<int> _afectacionesCovidSobreVentasList = [];
  String? _codigoCIIUActividadPrimaria;
  String? _codigoCIIUActividadComplementaria;
  String? _observacionesPatentes;
  Uint8List? _imagenDocumentoLegal;
  int _imageVersion = Random().nextInt(2000000);

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
                  onPressed: _agregarPropiedad,
                  child: Icon(Icons.add_circle_outlined),
                ),

                ...(propiedadesDelEdificio.asMap().entries.map((entry) {
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
                    onDeleted:
                        () => setState(
                          () => propiedadesDelEdificio.removeAt(idx),
                        ),
                    deleteIcon: Icon(Icons.close),
                    onPressed: () => _editarPropiedad(idx),
                  );
                }).toList()),
              ],
            ),
            SizedBox(height: 40),

            // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
            // ++++++++++++++++++++++   Cambio de Edificio a la propiedad   ++++++++++++++++++++++ //
            // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
            // Row(
            //   children: [
            //     Expanded(
            //       child: TextFormField(
            //         initialValue:
            //             widget.formGlobalStatus["noEdificio"].toString(),
            //         decoration: InputDecoration(labelText: 'noEdificio'),
            //         enabled: changeEdificio,
            //         validator: (value) {
            //           final number = int.tryParse(value!);
            //           if (number == null) {
            //             return "Ingresa una numero de edificio válido";
            //           }
            //           noEdificio = number;
            //         },
            //       ),
            //     ),
            //     Column(
            //       children: [
            //         Icon(
            //           Icons.edit,
            //           color: Theme.of(context).colorScheme.secondary,
            //         ),
            //         Checkbox(
            //           value: changeEdificio,
            //           onChanged: (bool? newValue) {
            //             setState(() {
            //               changeEdificio = newValue!;
            //             });
            //           },
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            TextFormField(
              key: ValueKey("noLocal-$noLocal"),
              initialValue: noLocal != null ? noLocal.toString() : "",
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
                noLocal = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("nivelPiso-$_nivelPiso"),
              initialValue: _nivelPiso != null ? _nivelPiso.toString() : "",
              decoration: InputDecoration(labelText: 'Nivel piso'),
              onChanged: (value) {
                _nivelPiso = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa el campo Nivel Piso';
                }
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("actividadPrimaria-$_actividadPrimaria"),
              initialValue:
                  _actividadPrimaria != null
                      ? _actividadPrimaria.toString()
                      : "",
              decoration: InputDecoration(labelText: 'Actividad primaria'),
              onChanged: (value) {
                _actividadPrimaria = value;
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
                "actividadComplementaria-$_actividadComplementaria",
              ),
              initialValue:
                  _actividadComplementaria != null
                      ? _actividadComplementaria.toString()
                      : "",
              decoration: InputDecoration(
                labelText: 'Actividad complementaria',
              ),
              onChanged: (value) {
                _actividadComplementaria = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa la Actividad complementario';
                }
                return null;
              },
            ),
            DropdownButtonFormField(
              value: _estadoNegocio,
              items: _dropdownOptions["estadoNegocio"]!.entries
                  .map((estado) {
                    return DropdownMenuItem(
                      value: estado.key,
                      child: Text(estado.value),
                    );
                  })
                  .toList(growable: false),
              onChanged: (value) {
                setState(() {
                  _estadoNegocio = value;
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
              key: ValueKey("nombreNegocio-$_nombreNegocio"),
              initialValue:
                  _nombreNegocio != null ? _nombreNegocio.toString() : "",
              decoration: InputDecoration(labelText: 'Nombre negocio'),
              onChanged: (value) {
                _nombreNegocio = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa el nombre del negocio';
                }
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("cantidadParqueos-$_cantidadParqueos"),
              initialValue:
                  _cantidadParqueos != null ? _cantidadParqueos.toString() : "",
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
                _cantidadParqueos = number;
                return null;
              },
            ),
            DropdownButtonFormField(
              value: _documentoMostrado,
              items: _dropdownOptions["documentoMostrado"]!.entries
                  .map((documento) {
                    return DropdownMenuItem(
                      value: documento.key,
                      child: Text(documento.value),
                    );
                  })
                  .toList(growable: false),
              onChanged: (value) {
                _documentoMostrado = value;
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
              key: ValueKey("nombrePatentado-$_nombrePatentado"),
              initialValue:
                  _nombrePatentado != null ? _nombrePatentado.toString() : "",
              decoration: InputDecoration(labelText: 'Nombre del patentado'),
              onChanged: (value) {
                _nombrePatentado = value;
              },
              validator:
                  (value) =>
                      value != null && value.isNotEmpty
                          ? null
                          : "Ingrese el nombre del patentado",
            ),
            TextFormField(
              key: ValueKey("numeroPatenteComercial-$_numeroPatenteComercial"),
              initialValue:
                  _numeroPatenteComercial != null
                      ? _numeroPatenteComercial.toString()
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
                _numeroPatenteComercial = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("cedulaPatentado-$_cedulaPatentado"),
              initialValue:
                  _cedulaPatentado != null ? _cedulaPatentado.toString() : "",
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
                _cedulaPatentado = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("nombreActividadPatente-$_nombreActividadPatente"),
              initialValue:
                  _nombreActividadPatente != null
                      ? _nombreActividadPatente.toString()
                      : "",
              decoration: InputDecoration(
                labelText: 'Nombre de la actividad registrada en la patente',
              ),
              onChanged: (value) {
                _nombreActividadPatente = value;
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
              value: _tieneMasPatentes,
              title: Text("Tiene autorizadas más patentes"),
              onChanged: (bool? selected) {
                setState(() {
                  _tieneMasPatentes = selected!;
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
            TextFormField(
              enabled: _tieneMasPatentes,
              key: ValueKey("numeroPatente_2-$_numeroPatente_2"),
              initialValue:
                  _numeroPatente_2 != null ? _numeroPatente_2.toString() : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Número de patente 2'),
              validator: (value) {
                if (_tieneMasPatentes) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el número de patente comercial 2';
                  }
                  final number = int.tryParse(value!);
                  if (number == null) {
                    return 'Por favor ingresa un número válido';
                  }
                  _numeroPatente_2 = number;
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            CheckboxListTile(
              value: _tienePermisoSalud,
              title: Text("Tiene permiso de salud"),
              onChanged: (bool? selected) {
                setState(() {
                  _tienePermisoSalud = selected!;
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
            TextFormField(
              enabled: _tienePermisoSalud,
              key: ValueKey("numeroPermisoSalud-$_numeroPermisoSalud"),
              initialValue:
                  _numeroPermisoSalud != null
                      ? _numeroPermisoSalud.toString()
                      : "",
              decoration: InputDecoration(
                labelText: 'Número de permiso de salud',
              ),
              onChanged: (value) {
                _numeroPermisoSalud = value;
              },
              validator: (value) {
                if (_tienePermisoSalud && (value == null || value.isEmpty)) {
                  return 'Por favor ingresa el número de permiso de salud';
                }
                return null;
              },
            ),
            DateInput(
              key: ValueKey(
                'fechaVigenciaPermisoSalud-$_tienePermisoSalud-$_fechaVigenciaPermisoSalud',
              ),
              initialValue:
                  _fechaVigenciaPermisoSalud != null
                      ? _fechaVigenciaPermisoSalud.toString()
                      : "",
              firstDate: DateTime(2000, 1, 1),
              lastDate: DateTime(2100),
              labelText: 'Fecha de vigencia del permiso de salud',
              onChanged: (value) {
                _fechaVigenciaPermisoSalud = value;
              },
              validator: (value) {
                if (!_tienePermisoSalud) return null;
                if (value == null || value.isEmpty) {
                  return "Ingresa la fecha de vigencia del permiso de salud";
                }
              },
              enabled: () => _tienePermisoSalud,
              // enabled: _tienePermisoSalud,
            ),
            TextFormField(
              enabled: _tienePermisoSalud,
              key: ValueKey("codigoCIIUPermisoSalud-$_codigoCIIUPermisoSalud"),
              initialValue:
                  _codigoCIIUPermisoSalud != null
                      ? _codigoCIIUPermisoSalud.toString()
                      : "",
              decoration: InputDecoration(
                labelText: 'Código CIIU del permiso de salud',
              ),
              onChanged: (value) {
                _codigoCIIUPermisoSalud = value;
              },
              validator: (value) {
                if (_tienePermisoSalud && (value == null || value.isEmpty)) {
                  return 'Por favor ingresa el código CIIU del permiso de salud';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            CheckboxListTile(
              value: _seTrataDeLocalMercado,
              title: Text("Se trata de un local de mercado"),
              onChanged: (bool? selected) {
                setState(() {
                  _seTrataDeLocalMercado = selected!;
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
            TextFormField(
              enabled: _seTrataDeLocalMercado,
              key: ValueKey("numeroLocalMercado-$_numeroLocalMercado"),
              initialValue:
                  _numeroLocalMercado != null
                      ? _numeroLocalMercado.toString()
                      : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Número de local mercado'),
              validator: (value) {
                if (!_seTrataDeLocalMercado) return null;
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el número de local mercado';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                _numeroLocalMercado = number;
                return null;
              },
            ),
            SizedBox(height: 20),
            CheckboxListTile(
              value: _tienePatenteLicores,
              title: Text("Tiene patente de licores"),
              onChanged: (bool? selected) {
                setState(() {
                  _tienePatenteLicores = selected!;
                });
              },
              activeColor: Colors.blue,
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
            TextFormField(
              enabled: _tienePatenteLicores,
              key: ValueKey("numeroPatenteLicores-$_numeroPatenteLicores"),
              initialValue:
                  _numeroPatenteLicores != null
                      ? _numeroPatenteLicores.toString()
                      : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número de patente licores',
              ),
              validator: (value) {
                if (!_tienePatenteLicores) return null;
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el número de patente licores';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                _numeroPatenteLicores = number;
                return null;
              },
            ),
            DropdownButtonFormField(
              value: _areaActividad,
              items: _dropdownOptions["areaActividad"]!.entries
                  .map((area) {
                    return DropdownMenuItem(
                      value: area.key,
                      child: Text(area.value),
                    );
                  })
                  .toList(growable: false),
              onChanged: (value) {
                setState(() {
                  _areaActividad = value;
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
              key: ValueKey("telefonoPatentado-$_telefonoPatentado"),
              initialValue:
                  _telefonoPatentado != null
                      ? _telefonoPatentado.toString()
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
                _telefonoPatentado = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("correoElectronico-$_correoElectronico"),
              initialValue:
                  _correoElectronico != null
                      ? _correoElectronico.toString()
                      : "",
              decoration: InputDecoration(labelText: 'Correo electrónico'),
              onChanged: (value) {
                _correoElectronico = value;
              },
              validator:
                  (value) =>
                      value != null && value.isNotEmpty
                          ? null
                          : "Ingrese el correo electronico",
            ),
            TextFormField(
              key: ValueKey(
                "cantidadEmpleadosAntesCovid-$_cantidadEmpleadosAntesCovid",
              ),
              initialValue:
                  _cantidadEmpleadosAntesCovid != null
                      ? _cantidadEmpleadosAntesCovid.toString()
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
                _cantidadEmpleadosAntesCovid = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey(
                "cantidadEmpleadosActual-$_cantidadEmpleadosActual",
              ),
              initialValue:
                  _cantidadEmpleadosActual != null
                      ? _cantidadEmpleadosActual.toString()
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
                _cantidadEmpleadosActual = number;
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
                "afectacionesCovidPersonalDesempennoEmpresa-$_afectacionesCovidPersonalDesempennoEmpresa",
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children:
                  _dropdownOptions["afectacionesCovidPersonalDesempennoEmpresa"]!
                      .entries
                      .map((e) {
                        return CheckboxListTile(
                          value: _afectacionesCovidPersonalDesempennoEmpresaList
                              .contains(e.key),
                          title: Text(e.value),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          onChanged: (bool? selected) {
                            if (selected == true) {
                              _afectacionesCovidPersonalDesempennoEmpresaList
                                  .add(e.key);
                            } else {
                              _afectacionesCovidPersonalDesempennoEmpresaList
                                  .remove(e.key);
                            }
                            setState(() {
                              _afectacionesCovidPersonalDesempennoEmpresa =
                                  _afectacionesCovidPersonalDesempennoEmpresaList
                                      .map((key) {
                                        return _dropdownOptions["afectacionesCovidPersonalDesempennoEmpresa"]![key]!;
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
                "afectacionesCovidSobreVentas-$_afectacionesCovidSobreVentas",
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children:
                  _dropdownOptions["afectacionesCovidSobreVentas"]!.entries.map((
                    e,
                  ) {
                    return CheckboxListTile(
                      value: _afectacionesCovidSobreVentasList.contains(e.key),
                      title: Text(e.value),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      onChanged: (bool? selected) {
                        if (selected == true) {
                          _afectacionesCovidSobreVentasList.add(e.key);
                        } else {
                          _afectacionesCovidSobreVentasList.remove(e.key);
                        }
                        setState(() {
                          _afectacionesCovidSobreVentas =
                              _afectacionesCovidSobreVentasList
                                  .map((key) {
                                    return _dropdownOptions["afectacionesCovidSobreVentas"]![key]!;
                                  })
                                  .join(', ');
                        });
                      },
                    );
                  }).toList(),
            ),
            TextFormField(
              key: ValueKey(
                "codigoCIIUActividadPrimaria-$_codigoCIIUActividadPrimaria",
              ),
              initialValue:
                  _codigoCIIUActividadPrimaria != null
                      ? _codigoCIIUActividadPrimaria.toString()
                      : "",
              decoration: InputDecoration(
                labelText: 'Código CIIU actividad primaria',
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  _codigoCIIUActividadPrimaria = value;
                  return null;
                }
                return "Ingrese el codigo CIIU de la actividad primaria";
              },
            ),
            TextFormField(
              key: ValueKey(
                "_codigoCIIUActividadComplementaria-$_codigoCIIUActividadComplementaria",
              ),
              initialValue:
                  _codigoCIIUActividadComplementaria != null
                      ? _codigoCIIUActividadComplementaria.toString()
                      : "",
              decoration: InputDecoration(
                labelText: 'Código CIIU actividad complementaria',
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  _codigoCIIUActividadComplementaria = value;
                  return null;
                }
                return "Ingrese el codigo CIIU de la actividad complementaria";
              },
            ),
            TextFormField(
              key: ValueKey("observacionesPatentes-$_observacionesPatentes"),
              initialValue:
                  _observacionesPatentes != null
                      ? _observacionesPatentes.toString()
                      : "",
              decoration: InputDecoration(labelText: 'Observaciones patentes'),
              onChanged: (value) {
                _observacionesPatentes = value;
              },
            ),
            SizedBox(height: 20),
            MyImagePicker(
              key: ValueKey(
                "imagenDocumentoLegal-${shortHash(_imagenDocumentoLegal ?? Uint8List(1))}",
              ),
              label: "Imagen de documento legal",
              initialValue: _imagenDocumentoLegal,
              context: context,
              validator: (imagebytes) {
                _imagenDocumentoLegal = imagebytes;
                return null;
              },
              onChanged: (imageBytes) {
                setState(() {
                  _imageVersion++;
                });
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
                    db.Propiedad? propiedadEnElNuevoLugar = await db
                        .getPropiedad(
                          idPredio: widget.formGlobalStatus["idPredio"]!,
                          noEdificio: noEdificio!,
                          noLocal: noLocal!,
                        );

                    ///\  /\  /\  /\  /\  /\  /\  /\  /\
                    ///\\//\\//\\//\\//\\//\\//\\//\\//\\
                    //  \/  \/  \/  \/  \/  \/  \/  \/  \\
                    bool nuevoIngreso =
                        widget.formGlobalStatus['noLocal'] == null;
                    bool edicion = !nuevoIngreso;
                    bool nadieEnElNuevoLugar = propiedadEnElNuevoLugar == null;
                    bool alguienEnElNuevoLugar = !nadieEnElNuevoLugar;
                    bool mismoLugarDeDestino =
                        widget.formGlobalStatus["idPredio"] == noEdificio &&
                        widget.formGlobalStatus["noEdificio"] == noEdificio &&
                        widget.formGlobalStatus["noLocal"] == noLocal;
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
                      } else if (nadieEnElNuevoLugar) {
                        casoEncontrado = 3;
                      } else if (alguienEnElNuevoLugar) {
                        casoEncontrado = 4;
                      }
                    }

                    final newPropiedad = db.Propiedad(
                      idPredio: idPredio!,
                      noEdificio: noEdificio!,
                      noLocal: noLocal!,
                      nivelPiso: _nivelPiso!,
                      actividadPrimaria: _actividadPrimaria!,
                      actividadComplementaria: _actividadComplementaria,
                      estadoNegocio: _estadoNegocio,
                      nombreNegocio: _nombreNegocio,
                      cantidadParqueos: _cantidadParqueos!,
                      documentoMostrado: _documentoMostrado,
                      nombrePatentado: _nombrePatentado,
                      numeroPatenteComercial: _numeroPatenteComercial,
                      cedulaPatentado: _cedulaPatentado,
                      nombreActividadPatente: _nombreActividadPatente,
                      tieneMasPatentes: _tieneMasPatentes,
                      numeroPatente_2: _numeroPatente_2,
                      tienePermisoSalud: _tienePermisoSalud,
                      numeroPermisoSalud: _numeroPermisoSalud,
                      fechaVigenciaPermisoSalud: _fechaVigenciaPermisoSalud,
                      codigoCIIUPermisoSalud: _codigoCIIUPermisoSalud,
                      seTrataDeLocalMercado: _seTrataDeLocalMercado,
                      numeroLocalMercado: _numeroLocalMercado,
                      tienePatenteLicores: _tienePatenteLicores,
                      numeroPatenteLicores: _numeroPatenteLicores,
                      areaActividad: _areaActividad,
                      telefonoPatentado: _telefonoPatentado,
                      correoElectronico: _correoElectronico,
                      cantidadEmpleadosAntesCovid: _cantidadEmpleadosAntesCovid,
                      cantidadEmpleadosActual: _cantidadEmpleadosActual,
                      afectacionesCovidPersonalDesempennoEmpresa:
                          _afectacionesCovidPersonalDesempennoEmpresa,
                      afectacionesCovidSobreVentas:
                          _afectacionesCovidSobreVentas,
                      codigoCIUUActividadPrimaria: _codigoCIIUActividadPrimaria,
                      codigoCIUUActividadComplementaria:
                          _codigoCIIUActividadComplementaria,
                      observacionesPatentes: _observacionesPatentes,
                      imagenDocumentoLegal: _imagenDocumentoLegal!,
                    );
                    try {
                      switch (casoEncontrado) {
                        case 1:
                          await newPropiedad.insertInDB();
                        case 2:
                          bool? accepted = await showAcceptDismissAlertDialog(
                            context,
                            message:
                                "Vas a sobrescribir un edificio ya existente. ¿Desea continuar?",
                          );
                          if (accepted == null || !accepted) return;
                          await propiedadEnElNuevoLugar!.deleteInDB();
                          await newPropiedad.insertInDB();
                        case 3:
                          newPropiedad.updateInDB(
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
                          await propiedadEnElNuevoLugar!.deleteInDB();
                          newPropiedad.updateInDB(
                            where: "id_predio = ? and no_edificio = ?",
                            whereArgs: [
                              widget.formGlobalStatus["idPredio"],
                              widget.formGlobalStatus["noEdificio"],
                            ],
                          );
                        case 5:
                          newPropiedad.updateInDB();
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

                    if (casoEncontrado != 5) {
                      widget.formGlobalStatus["noLocal"] = null;
                      return;
                    }
                    db
                        .getAllPropiedades(
                          idPredio: widget.formGlobalStatus["idPredio"],
                          noEdificio: widget.formGlobalStatus["noEdificio"],
                        )
                        .then((List<db.Propiedad> propiedades) {
                          setState(() {
                            propiedadesDelEdificio = propiedades;
                          });
                        });
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
  void _agregarPropiedad() {
    widget.formGlobalStatus["noLocal"] = null;
  }

  void _editarPropiedad(int idx) {
    _imageVersion++;
    widget.formGlobalStatus["noLocal"] = propiedadesDelEdificio[idx].noLocal;
  }
}
