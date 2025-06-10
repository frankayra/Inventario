import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:inventario/presentation/Screens/Form%20sections/Widgets/utiles/file_management.dart';

class ToolsSelection extends StatelessWidget {
  final tools = [
    ("Importar Mapa", () => null),
    ("Exportar BD",),
    ("Importar capa de delimitaciones",),
  ];
  ToolsSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // desenfoque del fondo
        // BackdropFilter(
        //   filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        //   child: Container(color: Colors.transparent),
        // ),
        // contenido centrado
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BigButton(context, "Importar Mapa", () async {
                  var selectedPath = await selectFile();
                  if (selectedPath == null) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("path cargado: $selectedPath")),
                  );
                }),
                BigButton(context, "Exportar BD", () async {
                  final selectedDirectory = await exportDBAsFile();
                  if (selectedDirectory != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "✅ Base de datos exportada a la ruta: $selectedDirectory",
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("❌ No se pudo exportar la base de datos"),
                      ),
                    );
                  }
                }),
                BigButton(context, "Importar capa de Delimitaciones", () async {
                  var selectedPath = await selectDirectory();
                  if (selectedPath == null) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("path cargado: $selectedPath")),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget BigButton(
  BuildContext context,
  String label,
  void Function() onPressed,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color.fromARGB(255, 65, 65, 65),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        minimumSize: const Size.fromHeight(120),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        textStyle: const TextStyle(fontSize: 20),
      ),
      child: Text(label),
    ),
  );
}
