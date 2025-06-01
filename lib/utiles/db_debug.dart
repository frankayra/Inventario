import 'package:flutter/material.dart';
import 'package:inventario/utiles/db_general_management.dart' as db;

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
  @override
  Widget build(BuildContext context) {
    db.getAllPredios().then((predios) {
      setState(() {
        _predios = predios;
        prediosWidgets =
            predios.map((predio) {
              return ListTile(
                title: Text('Predio ${predio.idPredio}'),
                subtitle: Text(''),
              );
            }).toList();
      });
    });
    _predios.map((predio) {
      db.getAllEdificios(idPredio: predio.idPredio).then((edificios) {
        setState(() {
          _edificios += edificios;
          edificiosWidgets +=
              edificios
                  .map(
                    (e) => ListTile(
                      title: Text('Edificio ${e.noEdificio}'),
                      subtitle: Text(''),
                    ),
                  )
                  .toList();
        });
      });
    }).toList();
    _edificios.map((edificio) {
      db
          .getAllPropiedades(
            idPredio: edificio.idPredio,
            noEdificio: edificio.noEdificio,
          )
          .then((propiedades) {
            setState(() {
              _propiedades += propiedades;
              propiedadesWidgets +=
                  propiedades
                      .map(
                        (p) => ListTile(
                          title: Text('Propiedad ${p.noLocal}'),
                          subtitle: Text(''),
                        ),
                      )
                      .toList();
            });
          });
    }).toList();

    // Aquí defines el widget que quieres mostrar como diálogo.
    // Típicamente será un AlertDialog.
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
  }
}
