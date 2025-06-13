import 'package:flutter/material.dart';
import 'package:inventario/Model/db_general_management.dart' as db;
import 'package:inventario/presentation/Widgets/dialogs.dart';
import 'package:inventario/Model/wrappers.dart';

class PredioFormController {
  final _dropdownOptions = {
    "acera": {0: 'No existe', 1: 'Bueno', 2: 'Regular', 3: 'Malo'},
  };
  bool changePredio = false;
  int? idPredio;
  double? nivelPredio1;
  double? nivelPredio2;
  double? nivelPredio3;
  int? acera;
  double? anchoAcera;
  String? observacionesTerreno;

  Future<void> validateForm(
    GlobalKey<FormState> formKey,
    BuildContext context,
    FormGlobalStatusWrapper<int> formGlobalStatus,
  ) async {
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
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error al guardar los datos')));
      }
    }
  }
}
