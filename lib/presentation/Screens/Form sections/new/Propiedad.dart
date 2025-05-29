import 'package:flutter/material.dart';
import 'package:inventario/presentation/Widgets/date_selection.dart';
import 'package:sqflite/sqflite.dart';
import 'package:inventario/utiles/db_general_management.dart';
import 'package:inventario/utiles/wrappers.dart';
import 'package:inventario/presentation/Widgets/image_selection.dart';
import 'package:image_picker/image_picker.dart';

// TODO: Como sera que se agregan nuevas instancias y se cambian los valores automaticamente.

class PropiedadForm extends StatefulWidget {
  final FormGlobalStatusWrapper formGlobalStatus;
  const PropiedadForm({super.key, required this.formGlobalStatus});

  @override
  State<PropiedadForm> createState() => PropiedadFormState();
}

class PropiedadFormState extends State<PropiedadForm> {
  List<Propiedad> propiedadesDelEdificio = [];
  final _formKey = GlobalKey<FormState>();
  final _dropdownOptions = {
    "estadoNegocio": {
      1: 'En operación',
      2: 'Cierre temporal',
      3: 'Desocupado con Rótulo SE ALQUILA',
      4: 'Cierre total',
      5: 'Ha modificado la actividad autorizada(EXPRESS u otra actividad)',
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
      getAllPropiedades(
        idPredio: widget.formGlobalStatus["idPredio"],
        noEdificio: widget.formGlobalStatus["noEdificio"],
      ).then((List<Propiedad> propiedades) {
        setState(() {
          propiedadesDelEdificio = propiedades;
        });
      });
    }
  }

  // ++++++ Módulo Uso de suelo y Patentes Comerciales ++++++ //

  bool changeEdificio = false;
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
  String? _codigoCIUUActividadPrimaria;
  String? _codigoCIUUActividadComplementaria;
  String? _observacionesPatentes;
  final MyImagePickerInput _imagenDocumentoLegal = MyImagePickerInput();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _agregarPropiedad,
                  child: Icon(Icons.add_circle_outlined),
                ),

                ...(propiedadesDelEdificio.asMap().entries.map((entry) {
                  final idx = entry.key;
                  return InputChip(
                    label: Text('Local ${entry.value.noLocal + 1}'),
                    backgroundColor: Colors.green[100],
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue:
                        widget.formGlobalStatus.variables["idPredio"]
                            .toString(),
                    decoration: InputDecoration(labelText: 'Localización'),
                    enabled: changeEdificio,
                    validator: (value) {
                      final number = int.tryParse(value!);
                      if (number == null ||
                          number < 1000000000 ||
                          number >= 10000000000) {
                        return "Ingresa una Localización válida";
                      }
                    },
                  ),
                ),
                Column(
                  children: [
                    Checkbox(
                      value: changeEdificio,
                      onChanged: (bool? newValue) {
                        setState(() {
                          changeEdificio = newValue!;
                        });
                      },
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                    ),
                    const Text('Cambiar'),
                  ],
                ),
              ],
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Nivel piso'),
              onChanged: (value) {
                _nivelPiso = value;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Actividad primaria'),
              onChanged: (value) {
                _actividadPrimaria = value;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Actividad complementaria',
              ),
              onChanged: (value) {
                _actividadComplementaria = value;
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
              decoration: InputDecoration(labelText: 'Nombre negocio'),
              onChanged: (value) {
                _nombreNegocio = value;
              },
            ),
            TextFormField(
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
                setState(() {
                  _documentoMostrado = value;
                });
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
              decoration: InputDecoration(labelText: 'Nombre del patentado'),
              onChanged: (value) {
                _nombrePatentado = value;
              },
            ),
            TextFormField(
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
              decoration: InputDecoration(
                labelText: 'Nombre de la actividad registrada en la patente',
              ),
              onChanged: (value) {
                _nombreActividadPatente = value;
              },
            ),
            Row(
              children: [
                Wrap(
                  children: [
                    Checkbox(
                      value: _tieneMasPatentes,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _tieneMasPatentes = newValue!;
                        });
                      },
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                    ),
                    const Text('Tiene autorizadas más patentes'),
                  ],
                ),
                Expanded(
                  child: TextFormField(
                    enabled: _tieneMasPatentes,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Número de patente 2',
                    ),
                    validator: (value) {
                      if (_tieneMasPatentes &&
                          (value == null || value.isEmpty)) {
                        return 'Por favor ingresa el número de patente comercial 2';
                      }
                      final number = int.tryParse(value!);
                      if (number == null) {
                        return 'Por favor ingresa un número válido';
                      }
                      _numeroPatente_2 = number;
                      return null;
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Wrap(
                  children: [
                    Checkbox(
                      value: _tienePermisoSalud,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _tienePermisoSalud = newValue!;
                        });
                      },
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                    ),
                    const Text('Tiene Permiso de salud'),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        enabled: _tienePermisoSalud,
                        decoration: InputDecoration(
                          labelText: 'Número de permiso de salud',
                        ),
                        onChanged: (value) {
                          _nombrePatentado = value;
                        },
                        validator: (value) {
                          if (_tienePermisoSalud &&
                              (value == null || value.isEmpty)) {
                            return 'Por favor ingresa el número de permiso de salud';
                          }
                          return null;
                        },
                      ),
                      DateInput(
                        startDate: DateTime(2000, 1, 1),
                        lastDate: DateTime(2100),
                        labelText: 'Fecha de vigencia del permiso de salud',
                        onChanged: (value) {
                          _fechaVigenciaPermisoSalud = int.parse(
                            "${value.year}${value.month.toString().padLeft(2, '0')}${value.day.toString().padLeft(2, '0')}",
                          );
                        },
                        // enabled: _tienePermisoSalud,
                      ),
                      TextFormField(
                        enabled: _tienePermisoSalud,
                        decoration: InputDecoration(
                          labelText: 'Código CIIU del permiso de salud',
                        ),
                        onChanged: (value) {
                          _codigoCIIUPermisoSalud = value;
                        },
                        validator: (value) {
                          if (_tienePermisoSalud &&
                              (value == null || value.isEmpty)) {
                            return 'Por favor ingresa el código CIIU del permiso de salud';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
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
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Nuevo registro'),
            // content: Text('Formulario para nueva instancia'),
            content: _PropiedadAux(),
            actions: [
              TextButton(
                onPressed: () async {
                  setState(
                    () async => propiedadesDelEdificio.add(
                      Propiedad(
                        // Claves
                        idPredio: widget.formGlobalStatus["idPredio"],
                        noEdificio: widget.formGlobalStatus["noEdificio"],
                        noLocal: noLocal!,
                        // Atributos
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
                        numeroPatente_2: _numeroPatente_2,
                        numeroPermisoSalud: _numeroPermisoSalud,
                        fechaVigenciaPermisoSalud: _fechaVigenciaPermisoSalud,
                        codigoCIIUPermisoSalud: _codigoCIIUPermisoSalud,
                        numeroLocalMercado: _numeroLocalMercado,
                        numeroPatenteLicores: _numeroPatenteLicores,
                        areaActividad: _areaActividad,
                        telefonoPatentado: _telefonoPatentado,
                        correoElectronico: _correoElectronico,
                        cantidadEmpleadosAntesCovid:
                            _cantidadEmpleadosAntesCovid,
                        cantidadEmpleadosActual: _cantidadEmpleadosActual,
                        afectacionesCovidPersonalDesempennoEmpresa:
                            _afectacionesCovidPersonalDesempennoEmpresa,
                        afectacionesCovidSobreVentas:
                            _afectacionesCovidSobreVentas,
                        codigoCIUUActividadPrimaria:
                            _codigoCIUUActividadPrimaria,
                        codigoCIUUActividadComplementaria:
                            _codigoCIUUActividadComplementaria,
                        observacionesPatentes: _observacionesPatentes,
                        tieneMasPatentes: _tieneMasPatentes,
                        tienePermisoSalud: _tienePermisoSalud,
                        seTrataDeLocalMercado: _seTrataDeLocalMercado,
                        tienePatenteLicores: _tienePatenteLicores,
                        imagenDocumentoLegal:
                            await _imagenDocumentoLegal.getImageBytes,
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

  void _editarPropiedad(int idx) {
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

class _PropiedadAux extends StatefulWidget {
  const _PropiedadAux({super.key});
  @override
  State<_PropiedadAux> createState() => _PropiedadAuxState();
}

class _PropiedadAuxState extends State<_PropiedadAux> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
