import '../controllers/storage/main.dart';
import '../models.dart';
import 'core.dart';

/// Extract coinID to get info from CoinGecko by it
String? getCoinID(CoinEntry coin) {
  final String symbol = coin.symbol.toUpperCase();
  final String? name = coin.name?.toLowerCase();
  final String? contractAddress = coin.contractAddress?.toLowerCase();
  final List<dynamic> allCoins = StorageController.allCoins.data[symbol] ?? [];

  // Check as a coin without smart contract
  if (contractAddress == null) {
    for (final Map<String, dynamic> item in allCoins) {
      if (item[EKey.contracts].isNotEmpty) continue;

      if (name != null && name != item[EKey.name].toLowerCase()) continue;

      return item[EKey.id];
    }
  }

  // Check as a token by smart contract
  for (final Map<String, dynamic> item in allCoins) {
    if (contractAddress != null &&
        !item[EKey.contracts].contains(contractAddress)) continue;

    if (name != null && name != item[EKey.name].toLowerCase()) continue;

    return item[EKey.id];
  }

  return null;
}
