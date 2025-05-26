import 'package:flutter/material.dart';
import 'package:inventario/presentation/Screens/Form%20sections/construccion.dart';
import 'package:inventario/presentation/Screens/Form%20sections/edificacion.dart';
import 'package:inventario/presentation/Screens/Form%20sections/medidores_electricos.dart';
import 'package:inventario/presentation/Screens/Form%20sections/terreno.dart';
import 'package:inventario/presentation/Screens/Form%20sections/uso_de_suelo_y_patentes_comerciales.dart';
import 'package:inventario/utiles/db_management.dart';

const EDIFICACION = 'Edificación';
const TERRENO = 'Terreno';
const MEDIDORES = 'Medidores Eléctricos';
const CONSTRUCCION = 'Construcción';
const USODESUELO = 'Uso de Suelo y Patentes Comerciales';

class FormularioInspeccion extends StatefulWidget {
  @override
  _FormularioInspeccionState createState() => _FormularioInspeccionState();
}

class _FormularioInspeccionState extends State<FormularioInspeccion> {
  final _formKey = GlobalKey<FormState>();

  bool mostrarCampoExtra = false;
  List<bool> seccionesExpandibles = List.filled(5, false);
  int? expandedSectionIndex;

  @override
  Widget build(BuildContext context) {
    final secciones = [
      _buildSection(EDIFICACION, EdificacionForm(), 0),
      _buildSection(TERRENO, TerrenoForm(), 1),
      _buildSection(USODESUELO, UsoDeSueloYPatentesForm(), 2),
      _buildSection(MEDIDORES, MedidoresForm(), 3),
      _buildSection(CONSTRUCCION, ConstruccionForm(), 4),
    ];

    return Form(
      key: _formKey,
      child: Column(
        children: [
          ListView.builder(
            itemCount: secciones.length,
            itemBuilder: (context, index) => secciones[index],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // final edificacion = Edificacion(
                  //   distrito: _distritoSeleccionado!,
                  //   edificio: _edificio!,
                  //   cantidadPisos: _cantidadPisos!,
                  //   cantidadSotanos: _cantidadSotanos!,
                  //   antejardin: _antejardin!,
                  //   materialFachada: _materialFachada!,
                  //   canoasBajantes: _canoasBajantes!,
                  //   observacionesEdificaciones: _observacionesEdificaciones,
                  // );
                  // await insertEdificacion(edificacion);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Datos guardados')));
                }
              },
              child: Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String titulo, Widget contenido, int index) {
    final backgroundColor = index.isEven ? Colors.grey[200] : Colors.white;
    return Container(
      color: backgroundColor,
      child: ExpansionPanelList(
        expansionCallback: (i, isExpanded) {
          setState(() {
            if (expandedSectionIndex != null) {
              seccionesExpandibles[expandedSectionIndex!] = false;
            }
            seccionesExpandibles[index] = isExpanded;
            expandedSectionIndex = index;
          });
        },
        children: [
          ExpansionPanel(
            headerBuilder:
                (context, isExpanded) => ListTile(title: Text(titulo)),
            body: Padding(padding: EdgeInsets.all(8.0), child: contenido),
            isExpanded: seccionesExpandibles[index],
            canTapOnHeader: true,
          ),
        ],
      ),
    );
  }
}
