import 'package:flutter/material.dart';
import 'package:inventario/presentation/Screens/form_screen.dart';

class UsoDeSueloYPatentesForm extends StatefulWidget {
  const UsoDeSueloYPatentesForm({super.key});

  @override
  State<UsoDeSueloYPatentesForm> createState() =>
      _UsoDeSueloYPatentesFormState();
}

class _UsoDeSueloYPatentesFormState extends State<UsoDeSueloYPatentesForm> {
  final List<Map<String, dynamic>> usosYSuelos = [];

  // +++++++++++++++++++++++++++++++ //
  // +++++++++ Constructor +++++++++ //
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
                  onPressed: () => _editarUsoSuelo(idx),
                );
              }).toList(),
        ),
        ElevatedButton(
          onPressed: _agregarUsoSuelo,
          child: Text('Añadir instancia'),
        ),
      ],
    );
  }

  // ++++++++++++++++++++++++++++++++++ //
  // ++++++++ Metodos Utiles ++++++++++ //
  // ++++++++++++++++++++++++++++++++++ //
  void _agregarUsoSuelo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Nuevo registro'),
            // content: Text('Formulario para nueva instancia'),
            content: EdificacionForm(),
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

  void _editarUsoSuelo(int idx) {
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

  // +++++++++++++++++++++++++++++++ //
  // +++++++++++ Widget ++++++++++++ //
  // +++++++++++++++++++++++++++++++ //
  // Widget _mainForm()
}
