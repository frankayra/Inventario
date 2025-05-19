import 'package:flutter/material.dart';

class FormularioInspeccion extends StatefulWidget {
  @override
  _FormularioInspeccionState createState() => _FormularioInspeccionState();
}

class _FormularioInspeccionState extends State<FormularioInspeccion> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> usosYSuelos = [];
  bool mostrarCampoExtra = false;
  List<bool> seccionesExpandibles = List.filled(5, false);

  @override
  Widget build(BuildContext context) {
    final secciones = [
      _buildSeccion('Edificación', _buildCamposEdificacion(), 0),
      _buildSeccion('Terreno', _buildCamposTerreno(), 1),
      _buildSeccionUsoYSuelo(2),
      _buildSeccion('Medidores eléctricos', _buildCamposMedidores(), 3),
      _buildSeccion('Construcción', _buildCamposConstruccion(), 4),
    ];

    return Form(
      key: _formKey,
      child: ListView.builder(
        itemCount: secciones.length,
        itemBuilder: (context, index) => secciones[index],
      ),
    );
  }

  Widget _buildSeccion(String titulo, Widget contenido, int index) {
    final backgroundColor = index.isEven ? Colors.grey[200] : Colors.white;
    return Container(
      color: backgroundColor,
      child: ExpansionPanelList(
        expansionCallback: (i, isExpanded) {
          setState(() => seccionesExpandibles[index] = !isExpanded);
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

  Widget _buildSeccionUsoYSuelo(int index) {
    return Container(
      color: index.isEven ? Colors.grey[200] : Colors.white,
      child: ExpansionPanelList(
        expansionCallback: (i, isExpanded) {
          setState(() => seccionesExpandibles[index] = !isExpanded);
        },
        children: [
          ExpansionPanel(
            headerBuilder:
                (context, isExpanded) => ListTile(
                  title: Text('Uso de suelo y Patentes comerciales'),
                ),
            body: Column(
              children: [
                Wrap(
                  spacing: 8,
                  children:
                      usosYSuelos.asMap().entries.map((entry) {
                        final idx = entry.key;
                        return InputChip(
                          label: Text('Instancia ${idx + 1}'),
                          backgroundColor: Colors.green[100],
                          onDeleted:
                              () => setState(() => usosYSuelos.removeAt(idx)),
                          deleteIcon: Icon(Icons.close),
                          onPressed: () => _editarUsoYSuelo(idx),
                        );
                      }).toList(),
                ),
                ElevatedButton(
                  onPressed: _agregarUsoYSuelo,
                  child: Text('Añadir instancia'),
                ),
              ],
            ),
            isExpanded: seccionesExpandibles[index],
            canTapOnHeader: true,
          ),
        ],
      ),
    );
  }

  void _agregarUsoYSuelo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Nueva instancia'),
            content: Text('Formulario para nueva instancia'),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() => usosYSuelos.add({'dummy': true}));
                  Navigator.pop(context);
                },
                child: Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void _editarUsoYSuelo(int idx) {
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

  Widget _buildCamposEdificacion() {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: 'Altura (m)'),
          keyboardType: TextInputType.number,
        ),
        SwitchListTile(
          title: Text('¿Tiene ascensor?'),
          value: mostrarCampoExtra,
          onChanged: (val) => setState(() => mostrarCampoExtra = val),
        ),
        if (mostrarCampoExtra)
          TextFormField(
            decoration: InputDecoration(labelText: 'Cantidad de ascensores'),
            keyboardType: TextInputType.number,
          ),
      ],
    );
  }

  Widget _buildCamposTerreno() {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: 'Área del terreno (m²)'),
          keyboardType: TextInputType.number,
        ),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: 'Tipo de terreno'),
          items:
              [
                'Urbano',
                'Rural',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) {},
        ),
      ],
    );
  }

  Widget _buildCamposMedidores() {
    return Column(
      children: [
        CheckboxListTile(
          title: Text('Tiene medidor eléctrico'),
          value: true,
          onChanged: (val) {},
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Número de serie'),
          keyboardType: TextInputType.text,
        ),
      ],
    );
  }

  Widget _buildCamposConstruccion() {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: 'Año de construcción'),
          keyboardType: TextInputType.number,
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.camera_alt),
          label: Text('Agregar foto'),
        ),
      ],
    );
  }
}
