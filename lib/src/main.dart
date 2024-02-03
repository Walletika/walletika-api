import 'dart:developer';

import 'controllers/api/main.dart';
import 'controllers/storage/main.dart';
import 'core/core.dart';
import 'models.dart';

class WalletikaAPI {
  static late FetchResult _fetchResult;
  static bool _isInitialized = false;
  static int _cacheTime = 0;
  static String _vsCurrenciesCache = 'usd';

  /// Get application version
  static String? get version => _fetchResult.version;

  /// Get listed networks
  static List<Map<String, dynamic>>? get listedNetworks =>
      _fetchResult.listedNetworks;

  /// Get listed coins
  static List<Map<String, dynamic>>? get listedCoins =>
      _fetchResult.listedCoins;

  /// Get offline coins
  static List<Map<String, dynamic>>? get offlineCoins =>
      _fetchResult.offlineCoins;

  /// Get stake contracts
  static List<Map<String, dynamic>>? get listedStakes =>
      _fetchResult.listedStakes;

  /// Get WalletikaAPI initialization status
  static bool get isInitialized => _isInitialized;

  /// WalletikaAPI is required to initialize before use
  static Future<void> init({
    required String encryptionKey,
    required String apiURL,
    String? apiDecryptionKey,
    String directory = 'storage',
  }) async {
    // Only once to initialize
    if (_isInitialized) {
      throw Exception("Walletika API already initialized");
    }

    // HTTP initialize
    httpOverridesInit();

    // Fetch data from the API
    _fetchResult = await fetcher(
      apiURL: apiURL,
      decryptionKey: apiDecryptionKey,
    );

    // Storage initialization and loading
    // `coinsImagesCached` must be initialized before `allCoins`, because it using first
    await StorageController.coinsImagesCached.init(
      fileName: DefaultInfo.coinsImagesCachedFileName,
      directory: directory,
      encryptionKey: encryptionKey,
    );
    await StorageController.coinsImagesCached.load();

    await StorageController.allCoins.init(
      fileName: DefaultInfo.allCoinsFileName,
      directory: directory,
      encryptionKey: encryptionKey,
    );
    await StorageController.allCoins.load().then((loaded) async {
      if (!loaded) await update();
    });

    await StorageController.offlineCoins
        .init(
      fileName: DefaultInfo.offlineCoinsFileName,
      directory: directory,
      encryptionKey: encryptionKey,
    )
        .whenComplete(() async {
      // Load last data in case API data not available
      if (_fetchResult.offlineCoins == null) {
        await StorageController.offlineCoins.load();
        return;
      }

      // Overwrite with the latest data
      for (final Map<String, dynamic> item in _fetchResult.offlineCoins!) {
        final OfflineCoin coin = OfflineCoin.fromJson(item);
        for (final String address in coin.contracts) {
          StorageController.offlineCoins.data[address] = coin.toJson();
        }
      }
      await StorageController.offlineCoins.dump();
    });

    // WalletikaAPI is initialized
    _isInitialized = true;
    log("WalletikaAPI.init result: $_isInitialized");
  }

  /// Check the internet connection
  static Future<bool> isConnected() {
    return APIController.isConnected();
  }

  /// Get a price list of coins
  static Future<List<CoinPrice>> getCoinsPrices(
    List<CoinEntry> coins, {
    String vsCurrencies = 'usd',
    bool checkCache = true,
  }) async {
    final List<CoinPrice> result = [];
    final Map<String, CoinEntry> remainingIds = {};

    for (final CoinEntry coin in coins) {
      final String? id = coin.id;
      double? price;
      double? changeIn24h;

      // Check from the cache
      if (checkCache && _isCacheValid(vsCurrencies)) {
        final CoinPrice? coinPrice =
            StorageController.coinsPricesCached.data[id];
        if (coinPrice != null) {
          price = coinPrice.price;
          changeIn24h = coinPrice.changeIn24h;
        }
      } else if (StorageController.coinsPricesCached.data.isNotEmpty) {
        StorageController.coinsPricesCached.data.clear();
      }

      // Check from `offlineCoins`
      if (price == null) {
        final String? address = coin.contractAddress?.toLowerCase();
        final Map<String, dynamic>? offCoin =
            StorageController.offlineCoins.data[address];

        if (offCoin?[EKey.contracts].contains(address) == true) {
          price = offCoin![EKey.price];
        }
      }

      if (price != null || id == null) {
        result.add(CoinPrice(
          id: id,
          symbol: coin.symbol,
          contractAddress: coin.contractAddress,
          price: price,
          changeIn24h: changeIn24h,
        ));

        continue;
      }

      remainingIds.addAll({id: coin});
    }

    // Check from the API
    if (remainingIds.isNotEmpty) {
      for (final CoinPrice coin in await APIController.getCoinsPrices(
        remainingIds,
        vsCurrencies: vsCurrencies,
      )) {
        result.add(coin);
        StorageController.coinsPricesCached.data[coin.id!] = coin;
      }

      _updateCache(vsCurrencies);
    }

    return result;
  }

  /// Get a coin price
  static Future<CoinPrice> getCoinPrice(
    CoinEntry coin, {
    String vsCurrencies = 'usd',
    bool checkCache = true,
  }) {
    return getCoinsPrices(
      [coin],
      vsCurrencies: vsCurrencies,
      checkCache: checkCache,
    ).then<CoinPrice>((coins) => coins.first);
  }

  /// Get a image list of coins
  static Future<List<CoinImage>> getCoinsImages(
    List<CoinEntry> coins, {
    bool checkCache = true,
  }) async {
    final List<CoinImage> result = [];
    final Map<String, CoinEntry> remainingIds = {};

    for (final CoinEntry coin in coins) {
      final String? id = coin.id;
      String? image;

      // Check from the cache
      if (checkCache) {
        image = StorageController.coinsImagesCached.data[id];
      }

      // Check from `offlineCoins`
      if (image == null) {
        final String? address = coin.contractAddress?.toLowerCase();
        final Map<String, dynamic>? offCoin =
            StorageController.offlineCoins.data[address];

        if (offCoin?[EKey.contracts].contains(address) == true) {
          image = offCoin?[EKey.image];
        }
      }

      if (image != null || id == null) {
        result.add(CoinImage(
          id: id,
          symbol: coin.symbol,
          contractAddress: coin.contractAddress,
          imageURL: image,
        ));

        continue;
      }

      remainingIds.addAll({id: coin});
    }

    // Check from the API
    if (remainingIds.isNotEmpty) {
      for (final CoinImage coin
          in await APIController.getCoinsImages(remainingIds)) {
        result.add(coin);
        if (coin.imageURL != null) {
          StorageController.coinsImagesCached.data[coin.id!] = coin.imageURL!;
        }
      }
      await StorageController.coinsImagesCached.dump();
    }

    return result;
  }

  /// Get a coin image
  static Future<CoinImage> getCoinImage(
    CoinEntry coin, {
    bool checkCache = true,
  }) {
    return getCoinsImages(
      [coin],
      checkCache: checkCache,
    ).then<CoinImage>((coins) => coins.first);
  }

  /// Update all coins data
  static Future<bool> update() async {
    bool isValid = false;

    final Map<String, List<dynamic>> result = await APIController.listCoins();

    if (result.isNotEmpty) {
      StorageController.allCoins.data.clear();
      StorageController.allCoins.data.addAll(result);
      await StorageController.allCoins.dump();

      StorageController.coinsImagesCached.data.clear();
      await StorageController.coinsImagesCached.dump();

      isValid = true;
    }

    return isValid;
  }

  static void _updateCache(String vsCurrencies) {
    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    _cacheTime = currentTime + 30000;
    _vsCurrenciesCache = vsCurrencies;
  }

  static bool _isCacheValid(String vsCurrencies) {
    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    bool isValid = false;

    if (currentTime < _cacheTime && vsCurrencies == _vsCurrenciesCache) {
      isValid = true;
    }

    return isValid;
  }
}
