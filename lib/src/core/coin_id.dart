import '../models.dart';
import 'core.dart';

String? getCoinID(CoinEntry coin) {
  final String symbol = coin.symbol.toUpperCase();
  final String? name = coin.name?.toLowerCase();
  final String? contractAddress = coin.contractAddress?.toLowerCase();

  for (final Map<String, dynamic> item in coins[symbol] ?? []) {
    if (contractAddress != null &&
        !item['contracts'].contains(contractAddress)) {
      continue;
    }

    if (name != null && name != item['name'].toLowerCase()) {
      continue;
    }

    return item['id'];
  }

  return null;
}
