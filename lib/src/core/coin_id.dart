import '../controllers/storage/main.dart';
import '../models.dart';
import 'core.dart';

/// Extract coinID to get info from CoinGecko by it
String? getCoinID(CoinEntry coin) {
  final String symbol = coin.symbol.toUpperCase();
  final String? name = coin.name?.toLowerCase();
  final String? contractAddress = coin.contractAddress?.toLowerCase();

  for (final Map<String, dynamic> item
      in StorageController.allCoins.data[symbol] ?? []) {
    if (contractAddress != null &&
        !item[EKey.contracts].contains(contractAddress)) continue;

    if (name != null && name != item[EKey.name].toLowerCase()) continue;

    return item[EKey.id];
  }

  return null;
}
