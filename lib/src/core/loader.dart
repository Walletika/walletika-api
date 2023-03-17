import 'dart:io';

import '../models.dart';
import 'core.dart';

Future<void> fetchCoinsListed() async {
  final Iterable<CoinListed> data = await fetcher(coinsListedAPI).then((coins) {
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

Future<void> load(Future<bool> Function() updater) async {
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

  if (await File(coinsCacheAESPath).exists()) {
    coinsCache.addAll(
      (jsonDecodeFromBytes(
        await cipher.decryptFromFile(path: coinsCacheAESPath),
      ) as Map)
          .cast<String, String>(),
    );
  }

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

Future<void> dump() async {
  await cipher.encryptToFile(
    data: jsonEncodeToBytes(coinsCache),
    path: coinsCachePath,
    ignoreFileExists: true,
  );
}
