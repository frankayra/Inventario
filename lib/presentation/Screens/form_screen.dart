import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../utiles/db_management.dart';

class EdificacionForm extends StatefulWidget {
  const EdificacionForm({super.key});
  @override
  _EdificacionFormState createState() => _EdificacionFormState();
}

class _EdificacionFormState extends State<EdificacionForm> {
  final _formKey = GlobalKey<FormState>();
  final _distritos = [
    'Carmen',
    'Merced',
    'Hospital',
    'Catedral',
    'Zapote',
    'San Francisco',
    'Uruca',
    'Mata Redonda',
    'Pavas',
  ]; // Lista de distritos de ejemplo
  String? _distritoSeleccionado;
  int? _edificio;
  int? _cantidadPisos;
  int? _cantidadSotanos;
  String? _antejardin;
  String? _materialFachada;
  String? _canoasBajantes;
  String? _observacionesEdificaciones;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              initialValue: 'Localización Automática',
              decoration: InputDecoration(labelText: 'Localización'),
              enabled: false,
            ),
            DropdownButtonFormField(
              value: _distritoSeleccionado,
              items:
                  _distritos.map((distrito) {
                    return DropdownMenuItem(
                      value: distrito,
                      child: Text(distrito),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _distritoSeleccionado = value;
                });
              },
              decoration: InputDecoration(labelText: 'Distrito'),
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona un distrito';
                }
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Edificio'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el número de edificio';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                _edificio = number;
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Cantidad pisos'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la cantidad de pisos';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                _cantidadPisos = number;
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Cantidad sótanos'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la cantidad de sótanos';
                }
                final number = int.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                _cantidadSotanos = number;
                return null;
              },
            ),
            DropdownButtonFormField(
              value: _antejardin,
              items:
                  [
                    'Si tiene',
                    'No tiene',
                    'En construcción (Código 996)',
                    'No aplica (Código 998)',
                  ].map((option) {
                    return DropdownMenuItem(value: option, child: Text(option));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _antejardin = value;
                });
              },
              decoration: InputDecoration(labelText: 'Antejardín'),
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona una opción';
                }
                return null;
              },
            ),
            DropdownButtonFormField(
              value: _materialFachada,
              items:
                  [
                    'Concreto',
                    'Prefabricado',
                    'Vidrio y Metal',
                    'Ladrillo',
                    'Madera',
                    'Mixto',
                    'No aplica (código 998)',
                    'No visible (código 999)',
                  ].map((option) {
                    return DropdownMenuItem(value: option, child: Text(option));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _materialFachada = value;
                });
              },
              decoration: InputDecoration(labelText: 'Material fachada'),
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona una opción';
                }
                return null;
              },
            ),
            DropdownButtonFormField(
              value: _canoasBajantes,
              items:
                  [
                    'No existe',
                    'Cumple',
                    'No cumple',
                    'No aplica (Código 998)',
                  ].map((option) {
                    return DropdownMenuItem(value: option, child: Text(option));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _canoasBajantes = value;
                });
              },
              decoration: InputDecoration(labelText: 'Canoas bajantes'),
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona una opción';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Observaciones edificaciones',
              ),
              onChanged: (value) {
                _observacionesEdificaciones = value;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final edificacion = Edificacion(
                      distrito: _distritoSeleccionado!,
                      edificio: _edificio!,
                      cantidadPisos: _cantidadPisos!,
                      cantidadSotanos: _cantidadSotanos!,
                      antejardin: _antejardin!,
                      materialFachada: _materialFachada!,
                      canoasBajantes: _canoasBajantes!,
                      observacionesEdificaciones: _observacionesEdificaciones,
                    );
                    await insertEdificacion(edificacion);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Datos guardados')));
                  }
                },
                child: Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
