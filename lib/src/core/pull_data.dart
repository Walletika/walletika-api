import 'dart:developer';
import 'dart:io';

import 'package:coingecko_api/coingecko_api.dart';
import 'package:coingecko_api/coingecko_result.dart';
import 'package:coingecko_api/data/coin_short.dart';

Future<Map<String, List<Map<String, dynamic>>>> pullData(
  CoinGeckoApi coinGeckoApi,
) async {
  await Directory('assets').create();
  final Map<String, List<Map<String, dynamic>>> result = {};
  int totalCoins = 0;

  try {
    final CoinGeckoResult<List<CoinShort>> response =
        await coinGeckoApi.coins.listCoins(includePlatforms: true);

    for (final CoinShort coin in response.data) {
      final String symbol = coin.symbol.toUpperCase();

      result[symbol] ??= [];
      result[symbol]!.add({
        "id": coin.id,
        "name": coin.name,
        "contracts":
            coin.platforms?.values.map((e) => e.toLowerCase()).toList() ?? [],
      });

      totalCoins++;
    }
  } catch (_) {
    // nothing to do
  }

  log("$totalCoins coins pulled successfully");
  return result;
}
