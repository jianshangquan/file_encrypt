import 'dart:io';

import 'package:dart_file_encrypt/algorithm/own_algorithm.dart';
import 'package:dart_file_encrypt/own_file_encrypt.dart';
import 'dart:io' show Platform;
import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  String currentDirPath = p.dirname(Platform.script.toString()).replaceAll("file:/", "");

  // String password = '349276185';
  // String inputFilePath = "/Users/jianshangquan/App Developemnt/Experiment projects/dart_file_encrypt/test-file/video.mp4";
  // String outputEncryptedPath = "/Users/jianshangquan/App Developemnt/Experiment projects/dart_file_encrypt/test-file/";
  // String outputDecryptedPath = "/Users/jianshangquan/App Developemnt/Experiment projects/dart_file_encrypt/test-file/";
  // OwnAlgorithm algorithm = OwnBinaryReverseAlgorithm(password: password);

  String? password;
  String? inputFilePath;
  String? outputPath;
  String? algorithmName;

  const keys = ['-i', '-o', '-p', '-a'];
  for (var i = 0; i < arguments.length; i++) {
    final arg = arguments[i];
    if (keys.contains(arg)) {
      final value = arguments[i + 1];
      i++;
      if (arg == '-i') {
        inputFilePath = p.normalize(p.join(currentDirPath, value));
      }
      if (arg == '-o') {
        outputPath = p.normalize(p.join(currentDirPath, value));
      }
      if (arg == '-p') {
        password = value;
      }
      if (arg == '-a') {
        algorithmName = value;
      }
    }
  }

  if (inputFilePath == null) throw Exception('Input file path required, add "-i <input path>" in you command');
  if (outputPath == null) throw Exception('Output folder path required, add "-o <output folder>" in your command');
  if (password == null) throw Exception('Password required, add "-p <your password>" in your command');

  bool isEncrypt = p.extension(inputFilePath) != '.encrypted';
  OwnAlgorithm algorithm = OwnAlgorithm.fromName(algorithmName ?? '', password) ?? OwnAlgorithm.defaultAlgorithm(password);

  try {
    if (isEncrypt) {
      await Encryptor.encryptFile(
        inputFilePath: Uri.decodeComponent(inputFilePath),
        outPath: Uri.decodeComponent(outputPath),
        algorithm: algorithm,
        onProgressing: (offset, total) {
          stdout.write('\rEncrypting : ${((offset / total) * 100).toStringAsFixed(1)}%');
        },
      );
    } else {
      await Decryptor.decryptFile(
        filePath: Uri.decodeComponent(inputFilePath),
        outPath: Uri.decodeComponent(outputPath),
        algorithm: algorithm,
        onProgressing: (offset, total) {
          stdout.write('\rDecrypting : ${((offset / total) * 100).toStringAsFixed(1)}%');
        },
      );
    }
  } catch (e) {
    print(e);
  }
}
