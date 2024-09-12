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
  bool isDecryptMode = false;

  const keys = ['-i', '-input', '-o', '-output', '-p', '-password', '-a', '-algorithm', '-d', '-decrypt'];
  for (var i = 0; i < arguments.length; i++) {
    final arg = arguments[i];
    if (keys.contains(arg)) {
      final value = i + 1 > arguments.length - 1 ? null : arguments[i + 1];
      if (arg == '-i' || arg == '-input') {
        inputFilePath = Uri.decodeComponent(p.normalize(p.join(currentDirPath, value)));
        i++;
      }
      if (arg == '-o' || arg == '-output') {
        outputPath = Uri.decodeComponent(p.normalize(p.join(currentDirPath, value)));
        i++;
      }
      if (arg == '-p' || arg == '-password') {
        password = value;
        i++;
      }
      if (arg == '-a' || arg == '-algorithm') {
        algorithmName = value;
        i++;
      }
      if (arg == '-d' || arg == '-decrypt') {
        isDecryptMode = true;
      }
    }
  }

  if (inputFilePath == null) throw Exception('Input file path required, add "-i <input path>" in you command');
  if (outputPath == null) throw Exception('Output folder path required, add "-o <output folder>" in your command');
  if (password == null) throw Exception('Password required, add "-p <your password>" in your command');

  bool isEncrypt = p.extension(inputFilePath) != '.encrypted' && !isDecryptMode;
  OwnAlgorithm algorithm = OwnAlgorithm.fromName(algorithmName ?? '', password) ?? OwnAlgorithm.defaultAlgorithm(password);

  final inputF = File(inputFilePath);
  final info = inputF.statSync();
  final isInputIsDirectory = info.type == FileSystemEntityType.directory;

  print(isDecryptMode);
  try {
    if ((isEncrypt || isInputIsDirectory) && !isDecryptMode) {
      if (isInputIsDirectory) {
        final files = await Directory(inputFilePath).list(recursive: true).where((file) => p.extension(file.path).isNotEmpty).toList();
        final fileLength = files.length;
        print('\nENCRYPTING FILES IN FOLDER');
        print('Total $fileLength found.! \n');
        for (var i = 0; i < fileLength; i++) {
          final file = files[i];
          print('ENCRYPTING : ${file.path}');
          final fName = p.basename(file.path);
          final relativePath = file.path.replaceAll(inputFilePath, "").replaceAll(fName, "");
          await Encryptor.encryptFile(
            inputFilePath: file.path,
            outPath: p.join(outputPath, './$relativePath'),
            algorithm: algorithm,
            onProgressing: (offset, total) {
              stdout.write('\rEncrypting ${fName} : ${((offset / total) * 100).toStringAsFixed(1)}%');
            },
          );
          print('\nCompleted $fName \n');
        }
      } else {
        await Encryptor.encryptFile(
          inputFilePath: inputFilePath,
          outPath: outputPath,
          algorithm: algorithm,
          onProgressing: (offset, total) {
            stdout.write('\rEncrypting : ${((offset / total) * 100).toStringAsFixed(1)}%');
          },
        );
      }
    } else {
      if (isInputIsDirectory) {
        final files = await Directory(inputFilePath).list(recursive: true).where((file) {
          final ext = p.extension(file.path);
          return ext.isNotEmpty && ext == '.encrypted';
        }).toList();
        final fileLength = files.length;
        print('\nENCRYPTING FILES IN FOLDER');
        print('Total $fileLength found.! \n');
        for (var i = 0; i < fileLength; i++) {
          final file = files[i];
          print('DECRYPTING : ${file.path}');
          final fName = p.basename(file.path);
          final relativePath = file.path.replaceAll(inputFilePath, "").replaceAll(fName, "");
          await Decryptor.decryptFile(
            filePath: file.path,
            outPath: p.join(outputPath, './$relativePath'),
            algorithm: algorithm,
            onProgressing: (offset, total) {
              stdout.write('\rDecrypting : ${((offset / total) * 100).toStringAsFixed(1)}%');
            },
          );
          print('\nCompleted $fName \n');
        }
      } else {
        await Decryptor.decryptFile(
          filePath: inputFilePath,
          outPath: outputPath,
          algorithm: algorithm,
          onProgressing: (offset, total) {
            stdout.write('\rDecrypting : ${((offset / total) * 100).toStringAsFixed(1)}%');
          },
        );
      }
    }
  } catch (e) {
    print(e);
  }
}
