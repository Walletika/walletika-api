import 'dart:developer';
import 'dart:io';

import 'package:aescrypto/aescrypto.dart';
import 'package:path/path.dart' as pathlib;

import '../../core/core.dart';
import '../../models.dart';

class StorageController<T> {
  static final allCoins = StorageController<List<dynamic>>();
  static final offlineCoins = StorageController<Map<String, dynamic>>();
  static final coinsImagesCached = StorageController<String>();

  /// For runtime only, Not initialized and unable to load and dump
  static final coinsPricesCached = StorageController<CoinPrice>();

  final Map<String, T> data = {};
  late String _dir;
  late String _path;
  late AESCrypto _cipher;

  /// Storage is required to initialize before use
  Future<void> init({
    required String fileName,
    required String directory,
    required String encryptionKey,
  }) async {
    _dir = directory;
    _path = pathlib.join(_dir, fileName);
    _cipher = AESCrypto(key: encryptionKey);

    final Directory dir = Directory(_dir);
    if (!await dir.exists()) {
      await dir.create();
    }

    log("WalletikaAPI.StorageController.init result: $_path");
  }

  /// Load data from drive to memory
  Future<bool> load() async {
    final String path = addAESExtension(_path);
    bool isValid = false;

    if (await File(path).exists()) {
      data.addAll(
        (jsonDecodeFromBytes(
          await _cipher.decryptFromFile(path: path),
        ) as Map)
            .cast<String, T>(),
      );

      isValid = true;
    }

    log("WalletikaAPI.StorageController.load result: $isValid from $path");
    return isValid;
  }

  /// Dump data from memory to drive
  Future<void> dump() async {
    final String outputPath = await _cipher.encryptToFile(
      data: jsonEncodeToBytes(data),
      path: _path,
      ignoreFileExists: true,
    );

    log("WalletikaAPI.StorageController.dump result: $outputPath");
  }
}
