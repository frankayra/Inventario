import 'package:flutter/material.dart';
import 'db_general_management.dart' as db;

class DBDebugDialog extends StatefulWidget {
  const DBDebugDialog({super.key});

  @override
  State<DBDebugDialog> createState() => _DBDebugDialogState();
}

class _DBDebugDialogState extends State<DBDebugDialog> {
  var _predios = <db.Predio>[];
  var _edificios = <db.Edificio>[];
  var _propiedades = <db.Propiedad>[];
  var prediosWidgets = <Widget>[];
  var edificiosWidgets = <Widget>[];
  var propiedadesWidgets = <Widget>[];
  bool isLoaded = false;
  Object? loadingError;

  @override
  void initState() {
    super.initState();
    initVariables();
  }

  Future<void> initVariables() async {
    try {
      _predios = await db.getAllPredios();
      for (var predio in _predios) {
        _edificios += await db.getAllEdificios(idPredio: predio.idPredio);
      }
      for (var edificio in _edificios) {
        _propiedades += await db.getAllPropiedades(
          idPredio: edificio.idPredio,
          noEdificio: edificio.noEdificio,
        );
      }
      print("""
        \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
        \/\/\/\/\/\/\/\/\/\/\/\/  Se termino de acceder a la BD  \/\/\/\/\/\/\/\/\/\/\/\/
        \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
      """);
      //
      //

      prediosWidgets =
          _predios.map((predio) {
            return Chip(label: Text('Pred. ${predio.idPredio}'));
          }).toList();
      edificiosWidgets +=
          _edificios
              .map((e) => Chip(label: Text('Ed. ${e.noEdificio}')))
              .toList();
      propiedadesWidgets +=
          _propiedades
              .map((p) => Chip(label: Text('Prop. ${p.noLocal}')))
              .toList();
    } catch (e) {
      loadingError = e;
    }
    if (mounted) {
      setState(() {
        isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoaded) {
      return AlertDialog(
        title: const Text('Base de datos'),
        content: Column(
          children: [
            Wrap(children: prediosWidgets),
            Wrap(children: edificiosWidgets),
            Wrap(children: propiedadesWidgets),
          ],
        ),
      );
    } else if (loadingError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $loadingError')),
      );
      return Container();
    }
    return Center(child: CircularProgressIndicator());
  }
}
