import 'package:flutter/material.dart';
import 'package:inventario/Model/db_general_management.dart' as db;
import 'package:inventario/ModelView/wrappers.dart';
import 'package:inventario/View/Widgets/dialogs.dart';
import 'package:inventario/View/Widgets/countdown_circle.dart';

class PredioFormController {
  bool currentValidPredio = false;
  bool changePredio = false;
  // +++++++++++++++++++++ Módulo Terreno +++++++++++++++++++++ //
  int? idPredio;
  double? nivelPredio1;
  double? nivelPredio2;
  double? nivelPredio3;
  int? acera;
  double? anchoAcera;
  String? observacionesTerreno;
  final dropdownOptions = {
    "acera": {0: 'No existe', 1: 'Bueno', 2: 'Regular', 3: 'Malo'},
  };
  final GlobalKey<FormState> formKey;
  final FormGlobalStatusWrapper<int> formGlobalStatus;
  final void Function() formSetStateCallbackFunction;
  PredioFormController({
    required this.formKey,
    required this.formGlobalStatus,
    required this.formSetStateCallbackFunction,
  }) {
    if (formGlobalStatus["idPredio"] != null) {
      idPredio = formGlobalStatus["idPredio"];
      db.getPredio(idPredio: idPredio!).then((predio) {
        if (predio != null) {
          currentValidPredio = true;
          nivelPredio1 = predio.nivelPredio1;
          nivelPredio2 = predio.nivelPredio2;
          nivelPredio3 = predio.nivelPredio3;
          acera = predio.acera;
          anchoAcera = predio.anchoAcera;
          observacionesTerreno = predio.observacionesTerreno;
          formSetStateCallbackFunction();
        }
      });
    }
  }

  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++               +++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++                 ++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++    Validacion   ++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++    Formulario   ++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++                 ++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++               +++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  Future<void> validateForm(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      if (idPredio == null ||
          idPredio! < 1000000000 ||
          idPredio! >= 10000000000) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Número de localización no válido')),
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
        idPredio: formGlobalStatus["idPredio"]!,
        nivelPredio1: nivelPredio1!,
        nivelPredio2: nivelPredio2!,
        nivelPredio3: nivelPredio3!,
        acera: acera!,
        anchoAcera: anchoAcera!,
        observacionesTerreno: observacionesTerreno,
      );
      try {
        await predio.insertInDB();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('✅ Datos guardados')));
        currentValidPredio = true;
        formSetStateCallbackFunction();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error al guardar los datos')));
      }
    }
  }

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++      +++++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++          +++++++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++   Utiles   ++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++          +++++++++++++++++++++++++++++++ //
  // +++++++++++++++++++++++++++      +++++++++++++++++++++++++++++++++ //
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ //
  void deletePredio(BuildContext context) async {
    bool dismissAction = false;
    try {
      final currentPredio = await db.getPredio(idPredio: idPredio!);
      if (currentPredio == null) return;
      final snakbaraction = ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Predio eliminado"),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      dismissAction = true;
                    },
                    child: Text(
                      "Deshacer",
                      style: TextStyle(color: Colors.blue[400]),
                    ),
                  ),
                  SizedBox(width: 15.0),
                  CountdownCircle(duration: Duration(seconds: 5)),
                ],
              ),
            ],
          ),
        ),

        // snackBarAnimationStyle: AnimationStyle(duration: Duration(seconds: 7)),
      );
      final start = DateTime.now();
      while (DateTime.now().difference(start) < Duration(seconds: 5)) {
        await Future.delayed(Duration(milliseconds: 200));
        if (dismissAction) {
          snakbaraction.close();
          return;
        }
      }

      ///\  /\  /\  /\  /\  /\  /\  /\  /\
      ///\\//\\//\\//\\//\\//\\//\\//\\//\\
      //  \/  \/  \/  \/  \/  \/  \/  \/  \\
      //            Acciones
      await currentPredio.deleteInDB();
      formGlobalStatus["idPredio"] = idPredio;
    } catch (e) {
      return;
    }
  }
}
