import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

abstract class OwnAlgorithm {
  int chunkSize = 1024 * 1024 * 1024 * 1024;
  String password = "";

  OwnAlgorithm({required this.password});

  List<int> getPasswordUnitCode() {
    return password.codeUnits;
  }

  String getPasswordHash() {
    final bytes = utf8.encode(password); // Convert the input string to bytes
    final digest = sha256.convert(bytes); // Compute the SHA-256 hash
    return digest.toString(); // Convert the hash to a hexadecimal string
  }

  Uint8List encrypt(Uint8List data);
  Uint8List decrypt(Uint8List data);
}
