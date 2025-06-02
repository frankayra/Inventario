import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:inventario/utiles/db_general_management.dart' as db;
import 'package:inventario/utiles/wrappers.dart';

class PredioForm extends StatefulWidget {
  final FormGlobalStatusWrapper<int> formGlobalStatus;
  const PredioForm({super.key, required this.formGlobalStatus});

  @override
  State<PredioForm> createState() => PredioFormState();
}

// TODO: Al presionar "Guardar", si se encuentra una tupla con el mismo ID, preguntar por confirmacion de cambio.
class PredioFormState extends State<PredioForm> {
  final _formKey = GlobalKey<FormState>();
  final _dropdownOptions = {
    "acera": {0: 'No existe', 1: 'Bueno', 2: 'Regular', 3: 'Malo'},
  };
  bool changePredio = false;
  int? idPredio;
  double? _nivelPredio1;
  double? _nivelPredio2;
  double? _nivelPredio3;
  int? _acera;
  double? _anchoAcera;
  String? _observacionesTerreno;
  @override
  Widget build(BuildContext context) {
    idPredio = widget.formGlobalStatus["idPredio"];
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: idPredio != null ? idPredio.toString() : "",
                    decoration: InputDecoration(labelText: 'Localización'),
                    enabled: changePredio,
                    onChanged: (value) {
                      final number = int.tryParse(value!);
                      if (number != null &&
                          (number >= 1000000000 || number < 10000000000)) {
                        widget.formGlobalStatus["idPredio"] = number;
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
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Nivel predio 1'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el nivel de predio 1';
                }
                final number = double.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                _nivelPredio1 = number;
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Nivel predio 2'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el nivel de predio 2';
                }
                final number = double.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                _nivelPredio2 = number;
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Nivel predio 3'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el nivel de predio 3';
                }
                final number = double.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                _nivelPredio3 = number;
                return null;
              },
            ),
            DropdownButtonFormField(
              value: _acera,
              items: _dropdownOptions["acera"]!.entries
                  .map((tipoAcera) {
                    return DropdownMenuItem(
                      value: tipoAcera.key,
                      child: Text(tipoAcera.value),
                    );
                  })
                  .toList(growable: false),
              onChanged: (value) {
                setState(() {
                  _acera = value;
                });
              },
              decoration: InputDecoration(labelText: 'Acera'),
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona un estado de acera';
                }
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Ancho de la acera'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el ancho de la acera';
                }
                final number = double.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número válido';
                }
                _anchoAcera = number;
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Observaciones terreno'),
              onChanged: (value) {
                _observacionesTerreno = value;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final predio = db.Predio(
                      idPredio: widget.formGlobalStatus["idPredio"]!,
                      nivelPredio1: _nivelPredio1!,
                      nivelPredio2: _nivelPredio2!,
                      nivelPredio3: _nivelPredio3!,
                      acera: _acera!,
                      anchoAcera: _anchoAcera!,
                      observacionesTerreno: _observacionesTerreno,
                    );
                    await predio.insertInDB();
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
