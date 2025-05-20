import 'package:flutter/material.dart';
import 'package:inventario/presentation/Screens/Form%20sections/construccion.dart';
import 'package:inventario/presentation/Screens/Form%20sections/edificacion.dart';
import 'package:inventario/presentation/Screens/Form%20sections/medidores_electricos.dart';
import 'package:inventario/presentation/Screens/Form%20sections/terreno.dart';
import 'package:inventario/presentation/Screens/Form%20sections/uso_de_suelo_y_patentes_comerciales.dart';

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
      child: ListView.builder(
        itemCount: secciones.length,
        itemBuilder: (context, index) => secciones[index],
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
