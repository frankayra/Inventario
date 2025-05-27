import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:inventario/utiles/db_general_management.dart';
import 'package:inventario/presentation/Screens/Form sections/new/Edificio.dart';
import 'package:inventario/presentation/Screens/Form sections/new/Predio.dart';

class PropiedadForm extends StatefulWidget {
  final GlobalKey<EdificioFormState> edificioFormKey;
  final GlobalKey<PredioFormState> predioFormKey;
  const PropiedadForm({
    super.key,
    required this.edificioFormKey,
    required this.predioFormKey,
  });

  @override
  State<PropiedadForm> createState() => PropiedadFormState();
}

class PropiedadFormState extends State<PropiedadForm> {
  List<Propiedad> propiedadesDelEdificio = [];

  @override
  Future<void> initState() async {
    super.initState();
    propiedadesDelEdificio = await getAllPropiedades(
      idPredio: widget.predioFormKey.currentState!.idPredio!,
      noEdificio: widget.edificioFormKey.currentState!.noEdificio!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: _agregarPropiedad,
              child: Icon(Icons.add_home),
            ),
            Wrap(
              spacing: 8,
              children:
                  propiedadesDelEdificio.asMap().entries.map((entry) {
                    final idx = entry.key;
                    return InputChip(
                      label: Text('Registro ${idx + 1}'),
                      backgroundColor: Colors.green[100],
                      onDeleted:
                          () => setState(
                            () => propiedadesDelEdificio.removeAt(idx),
                          ),
                      deleteIcon: Icon(Icons.close),
                      onPressed: () => _editarPropiedad(idx),
                    );
                  }).toList(),
            ),
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
            content: EdificacionForm(),
            actions: [
              TextButton(
                onPressed: () {
                  setState(
                    () => propiedadesDelEdificio.add(
                      Propiedad(
                        idPredio: idPredio,
                        noEdificio: noEdificio,
                        noLocal: noLocal,
                        nivelPiso: nivelPiso,
                        actividadPrimaria: actividadPrimaria,
                        cantidadParqueos: cantidadParqueos,
                        tieneMasPatentes: tieneMasPatentes,
                        tienePermisoSalud: tienePermisoSalud,
                        seTrataDeLocalMercado: seTrataDeLocalMercado,
                        tienePatenteLicores: tienePatenteLicores,
                        imagenDocumentoLegal: imagenDocumentoLegal,
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
