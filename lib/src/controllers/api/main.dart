import 'dart:developer';

import 'package:coingecko_api/coingecko_api.dart';
import 'package:coingecko_api/coingecko_result.dart';
import 'package:coingecko_api/data/coin.dart';
import 'package:coingecko_api/data/coin_short.dart';
import 'package:coingecko_api/data/price_info.dart';

import '../../core/core.dart';
import '../../models.dart';

class APIController {
  static final CoinGeckoApi _coinGeckoAPI = CoinGeckoApi();

  /// Ping to check the internet connection
  static Future<bool> isConnected() async {
    final bool result = await _coinGeckoAPI.ping
        .ping()
        .then<bool>((result) => result.data)
        .catchError((error) => false);

    log("WalletikaAPI.APIController.isConnected result: $result");
    return result;
  }

  /// Get a price list of coins
  static Future<List<CoinPrice>> getCoinsPrices(
    Map<String, CoinEntry> ids, {
    String vsCurrencies = 'usd',
  }) async {
    final List<CoinPrice> result = [];
    CoinGeckoResult<List<PriceInfo>>? listPrices;

    try {
      listPrices = await _coinGeckoAPI.simple.listPrices(
        ids: ids.keys.toList(),
        vsCurrencies: [vsCurrencies],
        include24hChange: true,
      );
    } catch (_) {
      // nothing to do
    }

    for (final MapEntry<String, CoinEntry> item in ids.entries) {
      final String id = item.key;
      final CoinEntry coin = item.value;
      double? price;
      double? changeIn24h;

      if (listPrices != null) {
        for (final PriceInfo priceInfo in listPrices.data) {
          if (priceInfo.id == id) {
            price = priceInfo.getPriceIn(vsCurrencies);
            changeIn24h = priceInfo.get24hChangeIn(vsCurrencies);
            break;
          }
        }
      }

      result.add(CoinPrice(
        id: id,
        symbol: coin.symbol,
        contractAddress: coin.contractAddress,
        price: price,
        changeIn24h: changeIn24h,
      ));
    }

    log("WalletikaAPI.APIController.getCoinsPrices result: $result");
    return result;
  }

  /// Get a image list of coins
  static Future<List<CoinImage>> getCoinsImages(
    Map<String, CoinEntry> ids,
  ) async {
    final List<CoinImage> result = [];

    for (final MapEntry<String, CoinEntry> item in ids.entries) {
      final String id = item.key;
      final CoinEntry coin = item.value;
      CoinGeckoResult<Coin?>? coinData;

      try {
        coinData = await _coinGeckoAPI.coins.getCoinData(
          id: id,
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

      result.add(CoinImage(
        id: id,
        symbol: coin.symbol,
        contractAddress: coin.contractAddress,
        imageURL: coinData?.data?.image?.small,
      ));
    }

    log("WalletikaAPI.APIController.getCoinsImages result: $result");
    return result;
  }

  /// Get all supported coins from `CoinGeckoAPI`
  static Future<Map<String, List<Map<String, dynamic>>>> listCoinGecko() async {
    final Map<String, List<Map<String, dynamic>>> result = {};
    int totalCoins = 0;

    try {
      final CoinGeckoResult<List<CoinShort>> response =
          await _coinGeckoAPI.coins.listCoins(includePlatforms: true);

      for (final CoinShort coin in response.data) {
        final String symbol = coin.symbol.toUpperCase();

        result[symbol] ??= [];
        result[symbol]!.add({
          EKey.id: coin.id,
          EKey.name: coin.name,
          EKey.contracts:
              coin.platforms?.values.map((e) => e.toLowerCase()).toList() ?? [],
        });

        totalCoins++;
      }
    } catch (_) {
      // nothing to do
    }

    log("WalletikaAPI.APIController.listCoinGecko result: $totalCoins coins received");
    return result;
  }

  /// Get all supported coins from `Walletika Repository`
  static Future<Map<String, List<Map<String, dynamic>>>> listCoins(
    String apiURL,
  ) async {
    final Map<String, List<Map<String, dynamic>>> result = await fetcher(
      apiURL: apiURL,
    ).then((result) => result.cast<String, List<Map<String, dynamic>>>());

    log("WalletikaAPI.APIController.listCoins result: ${result.length} coins received");
    return result;
  }
}
