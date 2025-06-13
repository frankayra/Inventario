import 'package:flutter/material.dart';
import 'package:inventario/Model/db_general_management.dart' as db;

Widget EncuestadorForm({required void Function(String) onSaved}) {
  final _subformKey = GlobalKey<FormState>();
  String? _name;
  return Padding(
    padding: const EdgeInsets.all(30.0),
    child: Center(
      child: Form(
        key: _subformKey,
        child: Row(
          children: [
            // Text("Nombre Encuestador", style: const TextStyle(fontSize: 30)),
            Expanded(
              child: TextFormField(
                initialValue: _name ?? "",
                decoration: InputDecoration(labelText: "Nombre encuestador"),
                validator: (value) {
                  if (value == null || value.trim().split(" ").length < 2) {
                    return "Ingresa tu nombre y apellidos";
                  }
                  _name = value.trim();
                  return null;
                },
              ),
            ),
            SizedBox(width: 30),
            ElevatedButton(
              onPressed: () async {
                if (_subformKey.currentState!.validate()) {
                  var encuestador = await db.getEncuestador();
                  var newEncuestador = db.Encuestador(name: _name!);
                  if (encuestador != null) {
                    await newEncuestador.updateInDB(
                      where: "name = ?",
                      whereArgs: [encuestador.name],
                    );
                  } else {
                    newEncuestador.insertInDB();
                  }
                  onSaved(_name!);
                }
              },
              child: Icon(Icons.arrow_forward_outlined),
            ),
          ],
        ),
      ),
    ),
  );
}
