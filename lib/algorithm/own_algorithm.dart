import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dart_file_encrypt/algorithm/own_aes_algorithm.dart';
import 'package:dart_file_encrypt/algorithm/own_binary_reverse_algorithm.dart';

abstract class OwnAlgorithm {
  int chunkSize = 1024 * 1024 * 1024 * 1024;
  String password = "";
  static String get name {
    return "";
  }

  OwnAlgorithm({required this.password});

  static OwnAlgorithm? fromName(String name, String password) {
    if (name == OwnAesAlgorithm.name) return OwnAesAlgorithm(password: password);
    if (name == OwnBinaryReverseAlgorithm.name) return OwnBinaryReverseAlgorithm(password: password);
    return null;
  }

  factory OwnAlgorithm.defaultAlgorithm(String password) {
    return OwnBinaryReverseAlgorithm(password: password);
  }

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
