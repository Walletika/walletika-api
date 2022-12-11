import 'dart:io';

import 'package:aescrypto/aescrypto.dart';
import 'package:coingecko_api/coingecko_result.dart';
import 'package:coingecko_api/data/coin.dart';
import 'package:coingecko_api/data/price_info.dart';
import 'package:path/path.dart' as pathlib;

import 'core/core.dart';
import 'models.dart';

class WalletikaAPI {
  static Future<void> init(
    String key, {
    String directory = 'assets',
  }) async {
    if (coins.isNotEmpty || coinsCache.isNotEmpty) {
      throw Exception("Walltika API already initialized");
    }

    cipher.setKey(key);

    mainDirectory = directory;
    coinsPath = pathlib.join(mainDirectory, 'coins.json');
    coinsAESPath = addAESExtension(coinsPath);
    coinsCachePath = pathlib.join(mainDirectory, 'coins_cache.json');
    coinsCacheAESPath = addAESExtension(coinsCachePath);
    coinsListedPath = pathlib.join(mainDirectory, 'coins_listed.json');
    coinsListedAESPath = addAESExtension(coinsListedPath);

    final Directory dir = Directory(mainDirectory);
    if (!await dir.exists()) await dir.create();

    await fetchCoinsListed();
    await load(update);
  }

  static Future<bool> isConnected() async {
    return coinGeckoAPI.ping
        .ping()
        .then<bool>((result) => result.data)
        .catchError((error) => false);
  }

  static void setDefaultCoinURLImage(String url) => defaultCoinURLImage = url;

  static Future<List<CoinPrice>> getCoinsPrices(
    List<CoinEntry> coins, {
    String vsCurrencies = 'usd',
    bool include24hChange = true,
  }) async {
    final List<CoinPrice> result = [];
    final Map<CoinEntry, String?> ids = {
      for (final CoinEntry coin in coins) coin: getCoinID(coin)
    };
    CoinGeckoResult<List<PriceInfo>>? coinsPrices;

    try {
      coinsPrices = await coinGeckoAPI.simple.listPrices(
        ids: ids.values.where((v) => v != null).toList().cast<String>(),
        vsCurrencies: [vsCurrencies],
        include24hChange: include24hChange,
      );
    } catch (_) {
      // nothing to do
    }

    for (final MapEntry<CoinEntry, String?> coin in ids.entries) {
      double? price;
      double? changeIn24h;

      for (final PriceInfo priceInfo in coinsPrices?.data ?? []) {
        if (priceInfo.id == coin.value) {
          price = priceInfo.getPriceIn(vsCurrencies);
          changeIn24h = priceInfo.get24hChangeIn(vsCurrencies);
          break;
        }
      }

      if (price == null && coin.value == null) {
        // Check coins listed
        for (final CoinListed coinListed in coinsListed) {
          if (coinListed.contracts.contains(
            coin.key.contractAddress?.toLowerCase(),
          )) {
            price = coinListed.price;
            break;
          }
        }
      }

      result.add(CoinPrice(
        symbol: coin.key.symbol,
        contractAddress: coin.key.contractAddress,
        price: price,
        changeIn24h: changeIn24h,
      ));
    }

    return result;
  }

  static Future<CoinPrice> getCoinPrice(
    CoinEntry coin, {
    String vsCurrencies = 'usd',
    bool include24hChange = true,
  }) async {
    return getCoinsPrices(
      [coin],
      vsCurrencies: vsCurrencies,
      include24hChange: include24hChange,
    ).then<CoinPrice>((coins) => coins.first);
  }

  static Future<List<CoinImage>> getCoinsImages(List<CoinEntry> coins) async {
    final List<CoinImage> result = [];
    final Map<CoinEntry, String?> ids = {
      for (final CoinEntry coin in coins) coin: getCoinID(coin)
    };
    bool isChanged = false;

    for (final MapEntry<CoinEntry, String?> coin in ids.entries) {
      String? image = coinsCache[coin.value];

      if (coin.value != null && image == null) {
        CoinGeckoResult<Coin?>? coinData;

        try {
          coinData = await coinGeckoAPI.coins.getCoinData(
            id: coin.value!,
            communityData: false,
            developerData: false,
            localization: false,
            marketData: false,
            sparkline: false,
            tickers: false,
          );
        } catch (_) {
          // nothing to do
        }

        image = coinData?.data?.image?.small;
        if (image != null) {
          coinsCache[coin.value!] = image;
          isChanged = true;
        }
      }

      if (image == null && coin.value == null) {
        // Check coins listed
        for (final CoinListed coinListed in coinsListed) {
          if (coinListed.contracts.contains(
            coin.key.contractAddress?.toLowerCase(),
          )) {
            image = coinListed.imageURL;
            break;
          }
        }
      }

      result.add(CoinImage(
        symbol: coin.key.symbol,
        contractAddress: coin.key.contractAddress,
        imageURL: image ?? defaultCoinURLImage,
      ));
    }

    if (isChanged) await dump();

    return result;
  }

  static Future<CoinImage> getCoinImage(CoinEntry coin) async {
    return getCoinsImages([coin]).then<CoinImage>((coins) => coins.first);
  }

  static Future<bool> update() async {
    bool isValid = false;

    final Map<String, List<dynamic>> coinsData = await pullData(coinGeckoAPI);

    if (coinsData.isNotEmpty) {
      coins.clear();
      coins.addAll(coinsData);
      await cipher.encryptToFile(
        data: jsonEncodeToBytes(coins),
        path: coinsPath,
        ignoreFileExists: true,
      );

      coinsCache.clear();
      await getCoinsImages([
        CoinEntry(symbol: 'ETH'),
        CoinEntry(symbol: 'BNB'),
        CoinEntry(symbol: 'MATIC'),
      ]);

      isValid = true;
    }

    return isValid;
  }
}
