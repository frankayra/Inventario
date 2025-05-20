import 'package:flutter/material.dart';

class UsoDeSueloYPatentesForm extends StatefulWidget {
  const UsoDeSueloYPatentesForm({super.key});

  @override
  State<UsoDeSueloYPatentesForm> createState() =>
      _UsoDeSueloYPatentesFormState();
}

class _UsoDeSueloYPatentesFormState extends State<UsoDeSueloYPatentesForm> {
  final List<Map<String, dynamic>> usosYSuelos = [];

  // +++++++++++++++++++++++++++++++ //
  // +++++++++++ Widget ++++++++++++ //
  // +++++++++++++++++++++++++++++++ //
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          children:
              usosYSuelos.asMap().entries.map((entry) {
                final idx = entry.key;
                return InputChip(
                  label: Text('Registro ${idx + 1}'),
                  backgroundColor: Colors.green[100],
                  onDeleted: () => setState(() => usosYSuelos.removeAt(idx)),
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
    );
  }

  // ++++++++++++++++++++++++++++++++++ //
  // ++++++++ Metodos Utiles ++++++++++ //
  // ++++++++++++++++++++++++++++++++++ //
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
}
