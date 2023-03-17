import 'package:aescrypto/aescrypto.dart';
import 'package:coingecko_api/coingecko_api.dart';

import '../models.dart';

/// Encryption instance, key will reset from WalletikaAPI instance
final AESCrypto cipher = AESCrypto(key: 'NoKey');

/// CoinGecko API instance
final CoinGeckoApi coinGeckoAPI = CoinGeckoApi();

/// All coins are pulled from CoinGecko
final Map<String, List<dynamic>> coins = {};

/// Coins are cashed for easy access
final Map<String, String> coinsCache = {};

/// Walletika coins are listed pre-publish on CoinGecko
final List<CoinListed> coinsListed = [];

/// Default unknown coin image ( Changeable )
String defaultCoinURLImage = 'https://etherscan.io/images/main/empty-token.png';
