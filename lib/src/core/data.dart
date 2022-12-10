import 'package:aescrypto/aescrypto.dart';
import 'package:coingecko_api/coingecko_api.dart';

import '../models.dart';

final AESCrypto cipher = AESCrypto(key: 'NoKey');
final CoinGeckoApi coinGeckoAPI = CoinGeckoApi();
final Map<String, List<dynamic>> coins = {};
final Map<String, String> coinsCache = {};
final List<CoinListed> coinsListed = [];
String defaultCoinURLImage = 'https://etherscan.io/images/main/empty-token.png';
