import 'package:flutter/material.dart';

Future<bool?> showAcceptDismissAlertDialog(
  BuildContext context, {
  required String message,
}) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder:
        (dialogContext) => AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text('Aceptar'),
            ),
          ],
        ),
  );
}
