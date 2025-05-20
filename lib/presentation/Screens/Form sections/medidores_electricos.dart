import 'package:flutter/material.dart';

class MedidoresForm extends StatefulWidget {
  const MedidoresForm({super.key});

  @override
  State<MedidoresForm> createState() => _MedidoresFormState();
}

class _MedidoresFormState extends State<MedidoresForm> {
  @override
  Widget build(BuildContext context) {
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
}
