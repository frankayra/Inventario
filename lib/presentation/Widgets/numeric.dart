import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:inventario/utiles/db_general_management.dart' as db;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MyNumericInput extends FormField<int> {
  final String label;
  final String noValidValidationMessage;
  final bool nullable = false;
  MyNumericInput({
    required this.label,
    required this.noValidValidationMessage,
    Key? key,
    int? initialValue,
    FormFieldValidator<int>? validator,
  }) : super(
         key: key,
         initialValue: initialValue,
         validator: validator,
         builder: (state) {
           // tu UI, puedes usar state.errorText para mostrar errores
           return TextFormField(
             keyboardType: TextInputType.number,
             decoration: InputDecoration(labelText: label),
             validator: (value) {
               if (value == null || value.isEmpty) {
                 return noValidValidationMessage;
               }
               final number = int.tryParse(value);
               if (number == null) {
                 return 'Por favor ingresa un número válido';
               }
               return null;
             },
           );
         },
       );
}
