import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:inventario/utiles/db_general_management.dart' as db;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MyNumericInput extends StatefulWidget {
  final String label;
  final String noValidValidationMessage;
  final String? Function(int value)? extraValidationFunction;
  final bool nullable = false;
  const MyNumericInput({
    super.key,
    required this.label,
    required this.noValidValidationMessage,
    this.extraValidationFunction,
  }, [this.nullable]);

  @override
  State<MyNumericInput> createState() => _MyNumericInputState();
}

class _MyNumericInputState extends State<MyNumericInput> {
  int? _value;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: widget.labelText),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return widget.noValidValidationMessage;
        }
        final number = int.tryParse(value);
        if (number == null) {
          return 'Por favor ingresa un número válido';
        }

        _value = number;
        return null;
      },
    );
  }
}
