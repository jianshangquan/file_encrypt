// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:path/path.dart' as p;

import 'package:dart_file_encrypt/algorithm/own_algorithm.dart';

//**
//  format => [
//   version: 3 byte
//   password: 64 byte
//   extenstions: 20 byte
//   filename: 255 byte
//  ]
// */

const int VERSION_BYTE = 3;
const int PASSWORD_BYTE = 64;
const int EXTENSTIONS_BYTE = 20;
const int FILENAME_BYTE = 255;

Uint8List generateByteSpaceWithString(int count, String value) {
  assert(count >= value.length, "Value for byte ByteSpace should not larger.");
  final bytes = Uint8List(count);
  bytes.setAll(0, value.codeUnits);
  return bytes;
}

extension ListExt<T> on List<T> {
  List<T> range(int from, int? howManyItem) {
    return sublist(from, howManyItem == null ? null : from + howManyItem);
  }
}

typedef OnProgressing = void Function(int offset, int total);

class Encryptor {
  static Future<void> encryptFile({
    required String inputFilePath,
    required String outPath,
    required OwnAlgorithm algorithm,
    OnProgressing? onProgressing,
  }) async {
    final inputFile = File(inputFilePath);
    final inputFileName = p.basenameWithoutExtension(inputFilePath);
    final inputFileExt = p.extension(inputFilePath);
    final inputFileStat = await inputFile.stat();

    final outputFile = File(p.join(outPath, '$inputFileName.encrypted'));
    outputFile.createSync(recursive: true);

    final Stream<List<int>> inputStream = inputFile.openRead();
    final IOSink outputStream = outputFile.openWrite();

    final completer = Completer();

    // add version number for 64 bytes
    final versionBytes = generateByteSpaceWithString(VERSION_BYTE, '1');
    outputStream.add(versionBytes);

    // add password for 64 bytes
    outputStream.add(algorithm.getPasswordHash().codeUnits);

    // add extenstions for 20 bytes
    final extBytes = generateByteSpaceWithString(EXTENSTIONS_BYTE, inputFileExt);
    outputStream.add(extBytes);

    // add extenstions for 255bytes
    final fileNameBytes = generateByteSpaceWithString(FILENAME_BYTE, Uri.encodeComponent(inputFileName));
    outputStream.add(fileNameBytes);

    int offset = 0;

    inputStream.transform(StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<Uint8List> sink) {
        for (int i = 0; i < data.length; i += algorithm.chunkSize) {
          int end = (i + algorithm.chunkSize < data.length) ? i + algorithm.chunkSize : data.length;
          List<int> chunkData = data.sublist(i, end);
          sink.add(Uint8List.fromList(chunkData));
        }
      },
    )).listen((Uint8List data) async {
      Uint8List encryptedData = algorithm.encrypt(data);
      outputStream.add(encryptedData);
      offset = offset + data.length;
      if (onProgressing != null) onProgressing(offset, inputFileStat.size);
    }, onError: (e) async {
      print(e.toString());
      await outputStream.flush();
      completer.completeError(e);
    }, onDone: () async {
      await outputStream.flush();
      completer.complete();
    });
    return completer.future;
  }
}

class Decryptor {
  static int CURRENT_VERSION = 1;
  static Future<void> decryptFile({
    required String filePath,
    required outPath,
    required OwnAlgorithm algorithm,
    OnProgressing? onProgressing,
  }) async {
    final metadataFileBytes = VERSION_BYTE + PASSWORD_BYTE + EXTENSTIONS_BYTE + FILENAME_BYTE;
    final inputFile = File(filePath);
    final inputFileStat = await inputFile.stat();

    final List<int> metadata = (await inputFile.openRead(0, metadataFileBytes).toList())[0];

    final version = int.parse(utf8.decode(metadata.range(0, VERSION_BYTE).where((byte) => byte != 0).toList()));
    final password = utf8.decode(metadata.range(VERSION_BYTE, PASSWORD_BYTE).where((byte) => byte != 0).toList());
    final extenstion = utf8.decode(metadata.range(VERSION_BYTE + PASSWORD_BYTE, EXTENSTIONS_BYTE).where((byte) => byte != 0).toList());
    final fileName = Uri.decodeComponent(utf8.decode(metadata.range(VERSION_BYTE + PASSWORD_BYTE + EXTENSTIONS_BYTE, FILENAME_BYTE).where((byte) => byte != 0).toList()));

    if (version < CURRENT_VERSION) throw Exception("The file that you encrypted with older version, please use lates update of version or decrypt it with same version");
    if (password != algorithm.getPasswordHash()) throw Exception("Invalid password");

    final fileFullName = '$fileName$extenstion';
    final outputFile = File('$outPath/$fileFullName');
    outputFile.createSync(recursive: true);

    final IOSink outputStream = outputFile.openWrite();
    final completer = Completer();

    int offset = 0;

    final inputStream = inputFile.openRead(metadataFileBytes);
    inputStream.transform(StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<Uint8List> sink) {
        for (int i = 0; i < data.length; i += algorithm.chunkSize) {
          int end = (i + algorithm.chunkSize < data.length) ? i + algorithm.chunkSize : data.length;
          List<int> chunkData = data.sublist(i, end);
          sink.add(Uint8List.fromList(chunkData));
        }
      },
    )).listen((Uint8List data) {
      Uint8List decryptedData = algorithm.decrypt(data);
      outputStream.add(decryptedData);
      offset = offset + data.length;
      if (onProgressing != null) onProgressing(offset, inputFileStat.size - metadataFileBytes);
    }, onError: (e) {
      print(e.toString());
      outputStream.flush();
      completer.completeError(e);
    }, onDone: () {
      outputStream.flush();
      completer.complete();
    });
    return completer.future;
  }
}
