import 'dart:io';

import 'package:aescrypto/aescrypto.dart';
import 'package:coingecko_api/coingecko_api.dart';
import 'package:coingecko_api/coingecko_result.dart';
import 'package:coingecko_api/data/coin.dart';
import 'package:coingecko_api/data/price_info.dart';

import 'core/core.dart';
import 'models.dart';

class WalletikaAPI {
  WalletikaAPI(String key, {this.walletikaImage}) {
    cipher = AESCrypto(key: key);
  }

  final CoinGeckoApi _coinGeckoAPI = CoinGeckoApi();
  final Map<String, List<dynamic>> _coins = {};
  final Map<String, String> _coinsCache = {};
  late AESCrypto cipher;
  final String? walletikaImage;
  String _defaultImage = 'https://etherscan.io/images/main/empty-token.png';
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void setDefaultCoinURLImage(String url) {
    _defaultImage = url;
  }

  Future<List<CoinPrice>> getCoinsPrices(
    List<CoinEntry> coins, {
    String vsCurrencies = 'usd',
    bool include24hChange = true,
  }) async {
    final List<CoinPrice> result = [];
    final Map<CoinEntry, String?> ids = {
      for (final CoinEntry coin in coins) coin: _getCoinID(coin)
    };
    CoinGeckoResult<List<PriceInfo>>? coinsPrices;

    try {
      coinsPrices = await _coinGeckoAPI.simple.listPrices(
        ids: ids.values.where((v) => v != null).toList().cast<String>(),
        vsCurrencies: [vsCurrencies],
        include24hChange: include24hChange,
      );
      _isConnected = true;
    } catch (_) {
      _isConnected = false;
    }

    for (final MapEntry<CoinEntry, String?> coin in ids.entries) {
      double? price;
      double? changeIn24h;

      try {
        final PriceInfo priceInfo = coinsPrices!.data.firstWhere(
          (priceInfo) => priceInfo.id == coin.value,
        );
        price = priceInfo.getPriceIn(vsCurrencies);
        changeIn24h = priceInfo.get24hChangeIn(vsCurrencies);
      } catch (_) {
        // Skip unknown coin
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

  Future<CoinPrice> getCoinPrice(
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

  Future<List<CoinImage>> getCoinsImages(List<CoinEntry> coins) async {
    final List<CoinImage> result = [];
    final Map<CoinEntry, String?> ids = {
      for (final CoinEntry coin in coins) coin: _getCoinID(coin)
    };
    bool isChanged = false;

    for (final MapEntry<CoinEntry, String?> coin in ids.entries) {
      String? image = _coinsCache[coin.value];

      if (coin.value != null && image == null) {
        CoinGeckoResult<Coin?>? coinData;

        try {
          coinData = await _coinGeckoAPI.coins.getCoinData(
            id: coin.value!,
            communityData: false,
            developerData: false,
            localization: false,
            marketData: false,
            sparkline: false,
            tickers: false,
          );
          _isConnected = true;
        } catch (_) {
          _isConnected = false;
        }

        image = coinData?.data?.image?.small;
        if (image != null) {
          _coinsCache[coin.value!] = image;
          isChanged = true;
        }
      }

      // Get walletika image, as long as this token is not available on coingecko
      if (image == null && coin.key.symbol == 'WTK' && walletikaImage != null) {
        image = walletikaImage;
      }

      result.add(CoinImage(
        symbol: coin.key.symbol,
        contractAddress: coin.key.contractAddress,
        imageURL: image ?? _defaultImage,
      ));
    }

    if (isChanged) await _dump();

    return result;
  }

  Future<CoinImage> getCoinImage(CoinEntry coin) async {
    return getCoinsImages([coin]).then<CoinImage>((coins) => coins.first);
  }

  Future<bool> ping() async {
    _isConnected = await _coinGeckoAPI.ping
        .ping()
        .then((result) => result.data)
        .catchError((error) => false);

    return _isConnected;
  }

  Future<bool> update() async {
    bool isValid = false;

    final Map<String, List<dynamic>> coinsData = await pullData(_coinGeckoAPI);

    if (coinsData.isNotEmpty) {
      _coins.clear();
      _coins.addAll(coinsData);
      await cipher.encryptToFile(
        data: jsonEncodeToBytes(_coins),
        path: coinsPath,
        ignoreFileExists: true,
      );

      _coinsCache.clear();
      await getCoinsImages([
        CoinEntry(symbol: 'ETH'),
        CoinEntry(symbol: 'BNB'),
        CoinEntry(symbol: 'MATIC'),
      ]);

      isValid = true;
    }

    return isValid;
  }

  Future<void> load() async {
    if (_coins.isNotEmpty || _coinsCache.isNotEmpty) {
      throw Exception("Already loaded before");
    }

    if (await File(coinsAESPath).exists()) {
      _coins.addAll(
        jsonDecodeFromBytes(
          await cipher.decryptFromFile(path: coinsAESPath),
        ).cast<String, List<dynamic>>(),
      );
    } else {
      await update();
    }

    if (await File(coinsCacheAESPath).exists()) {
      _coinsCache.addAll(
        jsonDecodeFromBytes(
          await cipher.decryptFromFile(path: coinsCacheAESPath),
        ).cast<String, String>(),
      );
    }

    await ping();
  }

  Future<void> _dump() async {
    await cipher.encryptToFile(
      data: jsonEncodeToBytes(_coinsCache),
      path: coinsCachePath,
      ignoreFileExists: true,
    );
  }

  String? _getCoinID(CoinEntry coin) {
    final String symbol = coin.symbol.toUpperCase();
    final String? name = coin.name?.toLowerCase();
    final String? contractAddress = coin.contractAddress?.toLowerCase();

    for (final Map<String, dynamic> item in _coins[symbol] ?? []) {
      if (contractAddress != null &&
          !item['contracts'].contains(contractAddress)) continue;

      if (name != null && name != item['name'].toLowerCase()) continue;

      return item['id'];
    }

    return null;
  }
}
