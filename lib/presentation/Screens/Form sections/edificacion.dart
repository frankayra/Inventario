import 'package:flutter/material.dart';

class EdificacionForm extends StatefulWidget {
  const EdificacionForm({super.key});

  @override
  State<EdificacionForm> createState() => _EdificacionFormState();
}

class _EdificacionFormState extends State<EdificacionForm> {
  bool mostrarCampoExtra = false;
  @override
  Widget build(BuildContext context) {
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
}
