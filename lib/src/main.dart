import 'dart:io';

import 'package:aescrypto/aescrypto.dart';
import 'package:coingecko_api/coingecko_result.dart';
import 'package:coingecko_api/data/coin.dart';
import 'package:coingecko_api/data/price_info.dart';
import 'package:path/path.dart' as pathlib;

import 'core/core.dart';
import 'models.dart';

class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class WalletikaAPI {
  /// Instance initialization is required
  static Future<void> init({
    required String encryptionKey,
    String? coinsListedAPI,
    String directory = 'assets',
  }) async {
    // Only once to initialize
    if (coins.isNotEmpty || coinsCache.isNotEmpty) {
      throw Exception("Walletika API already initialized");
    }

    // Set encryption key
    cipher.setKey(encryptionKey);

    // Bypass `CERTIFICATE_VERIFY_FAILED` exception by overrides http client
    HttpOverrides.global = _MyHttpOverrides();

    // Set file paths
    mainDirectory = directory;
    coinsPath = pathlib.join(mainDirectory, 'coins.json');
    coinsAESPath = addAESExtension(coinsPath);
    coinsCachePath = pathlib.join(mainDirectory, 'coins_cache.json');
    coinsCacheAESPath = addAESExtension(coinsCachePath);
    coinsListedPath = pathlib.join(mainDirectory, 'coins_listed.json');
    coinsListedAESPath = addAESExtension(coinsListedPath);

    // Create main folder if not exists
    final Directory dir = Directory(mainDirectory);
    if (!await dir.exists()) await dir.create();

    // Fetch that coins are listed by walletika
    if (coinsListedAPI != null) {
      await fetchCoinsListed(coinsListedAPI);
    }

    // Finally, update and load all files
    await load(update);
  }

  /// Ping to check connection
  static Future<bool> isConnected() async {
    return coinGeckoAPI.ping
        .ping()
        .then<bool>((result) => result.data)
        .catchError((error) => false);
  }

  /// Set default unknown coin image
  static void setDefaultCoinURLImage(String url) => defaultCoinURLImage = url;

  /// Get some coins prices
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

      // Get price and changes in 24h from API
      for (final PriceInfo priceInfo in coinsPrices?.data ?? []) {
        if (priceInfo.id == coin.value) {
          price = priceInfo.getPriceIn(vsCurrencies);
          changeIn24h = priceInfo.get24hChangeIn(vsCurrencies);
          break;
        }
      }

      // Check `CoinsListed`, If it's not available on API
      if (price == null && coin.value == null) {
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

  /// Get single coin price
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

  /// Get some coins images
  static Future<List<CoinImage>> getCoinsImages(List<CoinEntry> coins) async {
    final List<CoinImage> result = [];
    final Map<CoinEntry, String?> ids = {
      for (final CoinEntry coin in coins) coin: getCoinID(coin)
    };
    bool isChanged = false;

    for (final MapEntry<CoinEntry, String?> coin in ids.entries) {
      // Check `coinsCache`
      String? image = coinsCache[coin.value];

      // Get image from API, if it's not available in cache
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

      // Check `coinsListed`, if it's not available on API
      if (image == null && coin.value == null) {
        for (final CoinListed coinListed in coinsListed) {
          if (coinListed.contracts.contains(
            coin.key.contractAddress?.toLowerCase(),
          )) {
            image = coinListed.imageURL;
            break;
          }
        }
      }

      // Set `defaultCoinURLImage`, if it's not available everywhere
      result.add(CoinImage(
        symbol: coin.key.symbol,
        contractAddress: coin.key.contractAddress,
        imageURL: image ?? defaultCoinURLImage,
      ));
    }

    if (isChanged) await dump();

    return result;
  }

  /// Get single coin image
  static Future<CoinImage> getCoinImage(CoinEntry coin) async {
    return getCoinsImages([coin]).then<CoinImage>((coins) => coins.first);
  }

  /// Update for pulling all coins info from `CoinGeckoAPI`
  static Future<bool> update() async {
    bool isValid = false;

    final Map<String, List<dynamic>> coinsData = await pullData(coinGeckoAPI);

    if (coinsData.isNotEmpty) {
      // Dump coins data
      coins.clear();
      coins.addAll(coinsData);
      await cipher.encryptToFile(
        data: jsonEncodeToBytes(coins),
        path: coinsPath,
        ignoreFileExists: true,
      );

      // Get some coins to be available by default
      coinsCache.clear();
      await getCoinsImages([
        CoinEntry(symbol: 'ETH'),
        CoinEntry(symbol: 'BNB'),
        CoinEntry(symbol: 'MATIC'),
        CoinEntry(symbol: 'FTM'),
        CoinEntry(symbol: 'KLAY'),
        CoinEntry(symbol: 'AVAX'),
        CoinEntry(symbol: 'CFX'),
        CoinEntry(symbol: 'OKT'),
        CoinEntry(symbol: 'FLR'),
        CoinEntry(symbol: 'CRO'),
        CoinEntry(symbol: 'CELO'),
        CoinEntry(symbol: 'KCS'),
        CoinEntry(symbol: 'HT'),
        CoinEntry(symbol: 'TFUEL'),
        CoinEntry(symbol: 'IOTX'),
        CoinEntry(symbol: 'BRISE'),
        CoinEntry(symbol: 'CORE'),
      ]);

      isValid = true;
    }

    return isValid;
  }
}
