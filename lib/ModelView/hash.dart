import 'package:crypto/crypto.dart';
import 'dart:typed_data';

/// Devuelve un hash SHA-256 corto (primeros 8 caracteres en base16) de un Uint8List.
String shortHash(Uint8List bytes) {
  final digest = sha256.convert(bytes);
  return digest.toString().substring(
    0,
    8,
  ); // Puedes ajustar la longitud si quieres
}
