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

  bool changePredio = false;
  List<Widget> secciones = [];
  List<bool> seccionesExpandibles = List.filled(5, false);
  int? expandedSectionIndex;
  // bool statebuilt = false;
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
    secciones = [
      _buildSection(
        PREDIO,
        PredioForm(
          key: ValueKey(
            'predio-${formGlobalStatusWrapper.variables["idPredio"]}',
          ),
          formGlobalStatus: formGlobalStatusWrapper,
        ),
        0,
      ),
      if (formGlobalStatusWrapper['idPredio'] != null)
        _buildSection(
          EDIFICIOS,
          EdificioForm(
            key: ValueKey(
              'edificio-${formGlobalStatusWrapper.variables["idPredio"]}',
            ),
            formGlobalStatus: formGlobalStatusWrapper,
          ),
          1,
        ),
      if (formGlobalStatusWrapper['noEdificio'] != null)
        _buildSection(
          PROPIEDADES,
          PropiedadForm(
            key: ValueKey(
              'propiedad-${formGlobalStatusWrapper.variables["noEdificio"]}',
            ),
            formGlobalStatus: formGlobalStatusWrapper,
          ),
          2,
        ),
    ];
    int idPredio = formGlobalStatusWrapper["idPredio"];
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).scaffoldBackgroundColor,
                  const Color.fromARGB(255, 228, 228, 228),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: idPredio != null ? idPredio.toString() : "",
                    decoration: InputDecoration(labelText: 'Localización'),
                    enabled: changePredio,
                    onChanged: (value) {
                      final number = int.tryParse(value);
                      if (number != null &&
                          number >= 1000000000 &&
                          number < 10000000000) {
                        setState(() {
                          formGlobalStatusWrapper["idPredio"] = number;
                        });
                      }
                    },
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
                    Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    Checkbox(
                      value: changePredio,
                      onChanged: (bool? newValue) {
                        setState(() {
                          changePredio = newValue!;
                        });
                      },
                      // activeColor: Colors.blue,
                      // checkColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
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
      if (secciones.length >= 3) secciones.removeAt(2);
      if (secciones.length >= 2) secciones.removeAt(1);
      if (secciones.length >= 1) secciones.removeAt(0);
      formGlobalStatusWrapper.variables["idPredio"] = idPredio;
      formGlobalStatusWrapper.variables["noEdificio"] = null;
      formGlobalStatusWrapper.variables["noLocal"] = null;
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
      if (secciones.length >= 3) secciones.removeAt(2);
      if (secciones.length >= 2) secciones.removeAt(1);
      formGlobalStatusWrapper.variables["noEdificio"] = noEdificio;
      formGlobalStatusWrapper.variables["noLocal"] = null;
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
      if (secciones.length >= 3) secciones.removeAt(2);
      formGlobalStatusWrapper.variables["noLocal"] = noLocal;
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
