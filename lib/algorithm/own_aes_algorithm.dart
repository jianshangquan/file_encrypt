import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dart_file_encrypt/algorithm/own_algorithm.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/api.dart' as pc;

class OwnAesAlgorithm extends OwnAlgorithm {
  OwnAesAlgorithm({required super.password});

  @override
  Uint8List decrypt(Uint8List data) {
    // TODO: implement decrypt
    throw UnimplementedError();
  }

  @override
  Uint8List encrypt(Uint8List data) {
    // TODO: implement encrypt
    throw UnimplementedError();
  }
}
