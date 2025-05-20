import 'package:flutter/material.dart';

class ConstruccionForm extends StatefulWidget {
  const ConstruccionForm({super.key});

  @override
  State<ConstruccionForm> createState() => _ConstruccionFormState();
}

class _ConstruccionFormState extends State<ConstruccionForm> {
  @override
  Widget build(BuildContext context) {
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
