import 'dart:io';

import '../models.dart';
import 'core.dart';

/// Fetch all coins are listed by walletika
Future<void> fetchCoinsListed(String api) async {
  final Iterable<CoinListed> data = await fetcher(api).then((coins) {
    return coins.map<CoinListed>((coin) => CoinListed.fromJson(coin));
  });

  if (data.isNotEmpty) {
    coinsListed.clear();
    coinsListed.addAll(data);

    await cipher.encryptToFile(
      data: jsonEncodeToBytes(
        coinsListed.map((coin) => coin.toJson()).toList(),
      ),
      path: coinsListedPath,
      ignoreFileExists: true,
    );
  }
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
