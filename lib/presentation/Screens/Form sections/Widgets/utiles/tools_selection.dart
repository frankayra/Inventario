import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:inventario/presentation/Screens/Form%20sections/Widgets/utiles/file_management.dart';

class ToolsSelection extends StatelessWidget {
  final tools = [
    'Importar Mapa',
    "Exportar BD",
    "Importar capa de delimitaciones",
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
              children:
                  tools.map((tool) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 20,
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          // Acción al presionar el botón
                          var selectedPath = await selectFile();
                          if (selectedPath == null) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("path cargado: $selectedPath"),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(
                            255,
                            65,
                            65,
                            65,
                          ),
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                          minimumSize: const Size.fromHeight(120),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        child: Text(tool),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
