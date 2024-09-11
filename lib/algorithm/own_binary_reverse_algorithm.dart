import 'dart:typed_data';

import 'package:dart_file_encrypt/algorithm/own_algorithm.dart';
import 'dart:collection';

class OwnBinaryReverseAlgorithm extends OwnAlgorithm {
  OwnBinaryReverseAlgorithm({required super.password});

  @override
  Uint8List encrypt(Uint8List data) {
    final passwordCode = getPasswordUnitCode();
    final passwordCodeLength = passwordCode.length;
    final encrypted = Uint8List(data.length);
    for (var i = 0; i < data.length; i++) {
      encrypted[i] = data[i] + passwordCode[i % (passwordCodeLength - 1)];
    }
    return encrypted;
  }

  @override
  Uint8List decrypt(Uint8List data) {
    final passwordCode = getPasswordUnitCode();
    final passwordCodeLength = passwordCode.length;
    final decrypted = Uint8List(data.length);
    for (var i = 0; i < data.length; i++) {
      decrypted[i] = data[i] - passwordCode[i % (passwordCodeLength - 1)];
    }
    return decrypted;
  }
}
