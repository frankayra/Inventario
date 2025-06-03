import 'package:flutter/material.dart';
import 'package:inventario/presentation/Screens/Form%20sections/new/Predio.dart';
import 'package:inventario/presentation/Screens/Form%20sections/new/Edificio.dart';
import 'package:inventario/presentation/Screens/Form%20sections/new/Propiedad.dart';
import 'package:inventario/utiles/wrappers.dart';

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
  List<Widget> secciones = [];
  List<bool> seccionesExpandibles = List.filled(5, false);
  int? expandedSectionIndex;
  bool statebuilt = false;
  final formGlobalStatusWrapper =
      FormGlobalStatusWrapper<
        int
      >(); // Para manejar el estado global del formulario

  @override
  void initState() {
    super.initState();
    formGlobalStatusWrapper.variables['idPredio'] = widget.idPredio;
    formGlobalStatusWrapper.suscribeToVariableChangeEvent(
      variable: "idPredio",
      onChanged: idPredioChanged,
    );
    formGlobalStatusWrapper.suscribeToVariableChangeEvent(
      variable: "noEdificio",
      onChanged: noEdificioChanged,
    );
    formGlobalStatusWrapper.suscribeToVariableChangeEvent(
      variable: "noLocal",
      onChanged: noLocalChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!statebuilt) {
      secciones = [
        _buildSection(
          PREDIO,
          PredioForm(formGlobalStatus: formGlobalStatusWrapper),
          0,
        ),
        _buildSection(
          EDIFICIOS,
          EdificioForm(formGlobalStatus: formGlobalStatusWrapper),
          1,
        ),
        _buildSection(
          PROPIEDADES,
          PropiedadForm(formGlobalStatus: formGlobalStatusWrapper),
          2,
        ),
      ];
    }
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

  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++++++++++       ++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++++             +++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++++++   Callbacks   ++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++++             +++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++++++++++       ++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  void idPredioChanged(int? idPredio) {
    setState(() {
      formGlobalStatusWrapper.variables["idPredio"] = idPredio;
      formGlobalStatusWrapper.variables["noEdificio"] = null;
      formGlobalStatusWrapper.variables["noLocal"] = null;
      secciones.removeAt(2);
      secciones.removeAt(1);
      secciones.removeAt(0);
      secciones.addAll([
        _buildSection(
          PREDIO,
          PredioForm(formGlobalStatus: formGlobalStatusWrapper),
          0,
        ),
        _buildSection(
          EDIFICIOS,
          EdificioForm(formGlobalStatus: formGlobalStatusWrapper),
          1,
        ),
        _buildSection(
          PROPIEDADES,
          PropiedadForm(formGlobalStatus: formGlobalStatusWrapper),
          2,
        ),
      ]);
    });
  }

  void noEdificioChanged(int? noEdificio) {
    setState(() {
      formGlobalStatusWrapper.variables["noEdificio"] = noEdificio;
      formGlobalStatusWrapper.variables["noLocal"] = null;
      secciones.removeAt(2);
      secciones.removeAt(1);
      secciones.addAll([
        _buildSection(
          EDIFICIOS,
          EdificioForm(formGlobalStatus: formGlobalStatusWrapper),
          1,
        ),
        _buildSection(
          PROPIEDADES,
          PropiedadForm(formGlobalStatus: formGlobalStatusWrapper),
          2,
        ),
      ]);
    });
  }

  void noLocalChanged(int? noLocal) {
    setState(() {
      formGlobalStatusWrapper.variables["noLocal"] = noLocal;
      secciones.removeAt(2);
      secciones.addAll([
        _buildSection(
          PROPIEDADES,
          PropiedadForm(formGlobalStatus: formGlobalStatusWrapper),
          2,
        ),
      ]);
    });
  }
}
