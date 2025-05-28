import 'package:flutter/material.dart';
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

  @override
  Future<void> initState() async {
    super.initState();
    propiedadesDelEdificio = await getAllPropiedades(
      idPredio: widget.formGlobalStatus["idPredio"],
      noEdificio: widget.formGlobalStatus["noEdificio"],
    );
  }

  // ++++++ Módulo Uso de suelo y Patentes Comerciales ++++++ //

  int? noLocal;
  String? _nivelPiso;
  String? _actividadPrimaria;
  String? _actividadComplementaria;
  String? _estadoNegocio;
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
    return Column(
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
                    () => setState(() => propiedadesDelEdificio.removeAt(idx)),
                deleteIcon: Icon(Icons.close),
                onPressed: () => _editarPropiedad(idx),
              );
            }).toList()),
          ],
        ),
      ],
    );
  }

  // ++++++++++++++++++++++++++++++++++ //
  // ++++++++ Metodos Utiles ++++++++++ //
  // ++++++++++++++++++++++++++++++++++ //
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
                        idPredio: widget.formGlobalStatus["idPredio"],
                        noEdificio: widget.formGlobalStatus["noEdificio"],
                        noLocal: noLocal!,
                        nivelPiso: _nivelPiso!,
                        actividadPrimaria: _actividadPrimaria!,
                        cantidadParqueos: _cantidadParqueos!,
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
