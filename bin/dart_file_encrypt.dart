import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_file_encrypt/algorithm/own_algorithm.dart';
import 'package:dart_file_encrypt/algorithm/own_binary_reverse_algorithm.dart';
import 'package:dart_file_encrypt/own_file_encrypt.dart';

Future<void> main(List<String> arguments) async {
  String password = '349276185';
  String inputFilePath = "/Users/jianshangquan/App Developemnt/Experiment projects/dart_file_encrypt/test-file/video.mp4";
  String outputEncryptedPath = "/Users/jianshangquan/App Developemnt/Experiment projects/dart_file_encrypt/test-file/";
  String outputDecryptedPath = "/Users/jianshangquan/App Developemnt/Experiment projects/dart_file_encrypt/test-file/";
  OwnAlgorithm algorithm = OwnBinaryReverseAlgorithm(password: password);

  // await Encryptor.encryptFile(
  //   inputFilePath: inputFilePath,
  //   outPath: outputEncryptedPath,
  //   algorithm: algorithm,
  //   onProgressing: (offset, total) {
  //     stdout.write('\rEncrypting : ${((offset / total) * 100).toStringAsFixed(0)}%');
  //   },
  // );

  // // print('decrypting');
  await Decryptor.decryptFile(
    filePath: '$outputEncryptedPath/video.encrypted',
    outPath: outputDecryptedPath,
    algorithm: algorithm,
    onProgressing: (offset, total) {
      stdout.write('\rDecrypting : ${((offset / total) * 100).toStringAsFixed(0)}%');
    },
  );

  // print(algorithm.getPasswordHash());
  // print(utf8.decode('43bddaa4978d9e5cb46c93d85f83c4b1f193a3aaf068cca22f6c0b1d1a5e5d98'.codeUnits));
  // print('155904ef5ae392928442ef77f5fc2c73c4b4258ec2ec76f7a466d50d40d384a9'.length);
}
