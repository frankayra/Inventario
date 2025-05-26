import 'package:flutter/material.dart';
import 'package:inventario/presentation/Screens/Form%20sections/new/Predio.dart';
import 'package:inventario/presentation/Screens/Form%20sections/new/Edificio.dart';
import 'package:inventario/presentation/Screens/Form%20sections/new/Propiedad.dart';
import 'package:inventario/utiles/db_management.dart';

const PREDIO = 'Predio';
const EDIFICIOS = 'Edificios';
const PROPIEDADES = 'Propiedades';

class FormularioInspeccion extends StatefulWidget {
  final int idPredio;
  const FormularioInspeccion({required this.idPredio});
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
      _buildSection(EDIFICIOS, Edificio(idPredio: widget.idPredio), 0),
      // _buildSection(PREDIO, TerrenoForm(), 0),
      // _buildSection(PROPIEDADES, UsoDeSueloYPatentesForm(), 2),
    ];
    print("Se creo el array de secciones");
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          ...secciones,
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(onPressed: () async {}, child: Text("Listo")),
          ),
        ],
        //     ],
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
