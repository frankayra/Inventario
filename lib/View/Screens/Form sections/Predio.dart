import 'package:flutter/material.dart';
import 'package:inventario/ModelView/wrappers.dart';
import 'package:inventario/ModelView/PredioFormController.dart';

class PredioForm extends StatefulWidget {
  final FormGlobalStatusWrapper<int> formGlobalStatus;
  const PredioForm({super.key, required this.formGlobalStatus});

  @override
  State<PredioForm> createState() => PredioFormState();
}

class PredioFormState extends State<PredioForm> {
  final _formKey = GlobalKey<FormState>();
  late PredioFormController controller;
  bool changePredio = false;

  @override
  void initState() {
    controller = PredioFormController(
      formKey: _formKey,
      formGlobalStatus: widget.formGlobalStatus,
      formSetStateCallbackFunction: () => setState(() {}),
    );
    super.initState();
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
              key: ValueKey("nivelPredio1-${controller.nivelPredio1}"),
              initialValue:
                  controller.nivelPredio1 != null
                      ? controller.nivelPredio1.toString()
                      : "",
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
                controller.nivelPredio1 = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("nivelPredio2-${controller.nivelPredio2}"),
              initialValue:
                  controller.nivelPredio2 != null
                      ? controller.nivelPredio2.toString()
                      : "",
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
                controller.nivelPredio2 = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey("nivelPredio3-${controller.nivelPredio3}"),
              initialValue:
                  controller.nivelPredio3 != null
                      ? controller.nivelPredio3.toString()
                      : "",
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
                controller.nivelPredio3 = number;
                return null;
              },
            ),
            DropdownButtonFormField(
              value: controller.acera,
              items: controller.dropdownOptions["acera"]!.entries
                  .map((tipoAcera) {
                    return DropdownMenuItem(
                      value: tipoAcera.key,
                      child: Text(tipoAcera.value),
                    );
                  })
                  .toList(growable: false),
              onChanged: (value) {
                setState(() {
                  controller.acera = value;
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
              key: ValueKey("anchoAcera-${controller.anchoAcera}"),
              initialValue:
                  controller.anchoAcera != null
                      ? controller.anchoAcera.toString()
                      : "",
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
                controller.anchoAcera = number;
                return null;
              },
            ),
            TextFormField(
              key: ValueKey(
                "observacionesTerreno-${controller.observacionesTerreno}",
              ),
              initialValue:
                  controller.observacionesTerreno != null
                      ? controller.observacionesTerreno.toString()
                      : "",
              decoration: InputDecoration(labelText: 'Observaciones terreno'),
              onChanged: (value) {
                controller.observacionesTerreno = value;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async => await controller.validateForm(context),
                child: Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
