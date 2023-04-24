import 'dart:io';

import '../models.dart';
import 'core.dart';

/// Load all coins are listed
Future<void> coinsListedLoader(List<Map<String, dynamic>>? data) async {
  if (data == null || data.isEmpty) return;

  coinsListed.clear();
  for (final Map<String, dynamic> coin in data) {
    coinsListed.add(CoinListed.fromJson(coin));
  }

  await cipher.encryptToFile(
    data: jsonEncodeToBytes(data),
    path: coinsListedPath,
    ignoreFileExists: true,
  );
}

/// Load all stored data
Future<void> load(Future<bool> Function() updater) async {
  // Load all CoinGecko coins
  if (await File(coinsAESPath).exists()) {
    coins.addAll(
      (jsonDecodeFromBytes(
        await cipher.decryptFromFile(path: coinsAESPath),
      ) as Map)
          .cast<String, List<dynamic>>(),
    );
  } else {
    await updater();
  }

  // Load all coins are cashed
  if (await File(coinsCacheAESPath).exists()) {
    coinsCache.addAll(
      (jsonDecodeFromBytes(
        await cipher.decryptFromFile(path: coinsCacheAESPath),
      ) as Map)
          .cast<String, String>(),
    );
  }

  // Load all coins are listed
  if (coinsListed.isEmpty && await File(coinsListedAESPath).exists()) {
    coinsListed.addAll(
      (jsonDecodeFromBytes(
        await cipher.decryptFromFile(path: coinsListedAESPath),
      ) as List)
          .map((coin) => CoinListed.fromJson(coin))
          .toList(),
    );
  }
}

/// Dump `coinsCache` only, `coins` and `coinsListed` are dump automatically
Future<void> dump() async {
  await cipher.encryptToFile(
    data: jsonEncodeToBytes(coinsCache),
    path: coinsCachePath,
    ignoreFileExists: true,
  );
}
