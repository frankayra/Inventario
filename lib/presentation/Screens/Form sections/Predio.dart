import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:inventario/Model/db_general_management.dart' as db;
import 'package:inventario/Model/wrappers.dart';
import 'package:inventario/presentation/Widgets/dialogs.dart';

class PredioForm extends StatefulWidget {
  final FormGlobalStatusWrapper<int> formGlobalStatus;
  const PredioForm({super.key, required this.formGlobalStatus});

  @override
  State<PredioForm> createState() => PredioFormState();
}

// TODO: No se deben crear predios si el idPredio no es valido.
// DONE: Al presionar "Guardar", si se encuentra una tupla con el mismo ID, preguntar por confirmacion de cambio.
// DONE: Cuando ya existe el predio en la BD, este formulario debe autorellenar sus campos con los datos de la tupla presentes en la BD.
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
  void initState() {
    super.initState();
    if (widget.formGlobalStatus["idPredio"] != null) {
      idPredio = widget.formGlobalStatus["idPredio"];
      db.getPredio(idPredio: idPredio!).then((predio) {
        if (predio != null) {
          print("""
            nivelPredio1: ${predio.nivelPredio1}
            nivelPredio2: ${predio.nivelPredio2}
            nivelPredio3: ${predio.nivelPredio3}
            acera: ${predio.acera}
            anchoAcera: ${predio.anchoAcera}
            observacionesTerreno: ${predio.observacionesTerreno}
          """);
          setState(() {
            _nivelPredio1 = predio.nivelPredio1;
            _nivelPredio2 = predio.nivelPredio2;
            _nivelPredio3 = predio.nivelPredio3;
            _acera = predio.acera;
            _anchoAcera = predio.anchoAcera;
            _observacionesTerreno = predio.observacionesTerreno;
          });
        }
      });
    }
  }

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
              key: ValueKey("nivelPredio1-$_nivelPredio1"),
              initialValue:
                  _nivelPredio1 != null ? _nivelPredio1.toString() : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Nivel predio 1'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el nivel de predio 1';
                }
                final number = double.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número decimal válido';
                }
                _nivelPredio1 = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("nivelPredio2-$_nivelPredio2"),
              initialValue:
                  _nivelPredio2 != null ? _nivelPredio2.toString() : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Nivel predio 2'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el nivel de predio 2';
                }
                final number = double.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número decimal válido';
                }
                _nivelPredio2 = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("nivelPredio3-$_nivelPredio3"),
              initialValue:
                  _nivelPredio3 != null ? _nivelPredio3.toString() : "",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Nivel predio 3'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el nivel de predio 3';
                }
                final number = double.tryParse(value);
                if (number == null) {
                  return 'Por favor ingresa un número decimal válido';
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
              key: ValueKey("anchoAcera-$_anchoAcera"),
              initialValue: _anchoAcera != null ? _anchoAcera.toString() : "",
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
              key: ValueKey("observacionesTerreno-$_observacionesTerreno"),
              initialValue:
                  _observacionesTerreno != null
                      ? _observacionesTerreno.toString()
                      : "",
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
                    if (idPredio == null ||
                        idPredio! < 1000000000 ||
                        idPredio! >= 10000000000) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Número de localización no válido'),
                        ),
                      );
                      return;
                    }
                    var oldPredio = await db.getPredio(idPredio: idPredio!);
                    if (oldPredio != null) {
                      var override = await showAcceptDismissAlertDialog(
                        context,
                        message:
                            "Se sobrescribirá la información del predio actual. ¿Desea continuar?",
                      );
                      if (override == null || !override) return;
                    }
                    final predio = db.Predio(
                      idPredio: widget.formGlobalStatus["idPredio"]!,
                      nivelPredio1: _nivelPredio1!,
                      nivelPredio2: _nivelPredio2!,
                      nivelPredio3: _nivelPredio3!,
                      acera: _acera!,
                      anchoAcera: _anchoAcera!,
                      observacionesTerreno: _observacionesTerreno,
                    );
                    try {
                      await predio.insertInDB();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('✅ Datos guardados')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Error al guardar los datos')),
                      );
                    }
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
