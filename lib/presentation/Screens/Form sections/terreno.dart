import 'package:flutter/material.dart';

class TerrenoForm extends StatefulWidget {
  const TerrenoForm({super.key});

  @override
  State<TerrenoForm> createState() => _TerrenoFormState();
}

class _TerrenoFormState extends State<TerrenoForm> {
  @override
  Widget build(BuildContext context) {
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
}
