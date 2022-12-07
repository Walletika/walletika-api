import 'package:aescrypto/aescrypto.dart';
import 'package:path/path.dart' as pathlib;

final String coinsPath = pathlib.join('assets', 'coins.json');
final String coinsAESPath = addAESExtension(coinsPath);
final String coinsCachePath = pathlib.join('assets', 'coins_cache.json');
final String coinsCacheAESPath = addAESExtension(coinsCachePath);
