import 'dart:typed_data';

import 'package:dart_file_encrypt/algorithm/own_algorithm.dart';
import 'dart:collection';

class OwnBinaryReverseAlgorithm extends OwnAlgorithm {
  late List<int> passwordHashCodeUnits;
  OwnBinaryReverseAlgorithm({required super.password}) {
    passwordHashCodeUnits = getPasswordHash().codeUnits;
  }

  @override
  static String get name => "PASSWORD-BINARY-REVERSE";

  @override
  Uint8List encrypt(Uint8List data) {
    final passwordCode = passwordHashCodeUnits;
    final passwordCodeLength = passwordCode.length;
    final encrypted = Uint8List(data.length);
    for (var i = 0; i < data.length; i++) {
      final calculatedData = data[i] + passwordCode[i % (passwordCodeLength - 1)];
      encrypted[data.length - (i + 1)] = calculatedData;
    }

    return encrypted;
  }

  @override
  Uint8List decrypt(Uint8List data) {
    final passwordCode = passwordHashCodeUnits;
    final passwordCodeLength = passwordCode.length;
    final decrypted = Uint8List(data.length);
    for (var i = 0; i < data.length; i++) {
      final calculatedData = data[data.length - (i + 1)] - passwordCode[i % (passwordCodeLength - 1)];
      decrypted[i] = calculatedData;
    }
    return decrypted;
  }
}
