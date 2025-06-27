import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'db_general_management.dart' as db;

class InquiryInfo extends StatefulWidget {
  final String mapName;
  const InquiryInfo({super.key, required this.mapName});

  @override
  State<InquiryInfo> createState() => _InquiryInfoState();
}

class _InquiryInfoState extends State<InquiryInfo> {
  var _predios = <db.Predio>[];
  var _edificios = <db.Edificio>[];
  var _propiedades = <db.Propiedad>[];
  Widget? predioWidget;
  Widget? edificioWidget;
  Widget? propiedadWidget;
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

      predioWidget = Chip(
        label: Text('Predios consultados: ${_predios.length}'),
      );
      edificioWidget = Chip(
        label: Text('Edificios consultados: ${_edificios.length}'),
      );
      propiedadWidget = Chip(
        label: Text('Propiedades consultados: ${_propiedades.length}'),
      );
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
        title: const Text('Información de la encuesta'),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Chip(
                label: Text(
                  'Mapa: ${widget.mapName}',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.black,
              ),
            ),
            Wrap(children: [predioWidget!, edificioWidget!, propiedadWidget!]),
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
