import 'dart:io';

import 'package:walletika_api/src/core/core.dart';
import 'package:walletika_api/walletika_api.dart';
import 'package:test/test.dart';

const debugging = true;
void printDebug(String message) {
  if (debugging) print(message);
}

void main() async {
  const String api =
      'https://github.com/Walletika/metadata/raw/main/app_info_test.json';

  group('Walletika API Offline Group:', () {
    test('Test (init)', () async {
      await WalletikaAPI.init(encryptionKey: '123456', apiURL: api);
      bool isConnected = await WalletikaAPI.isConnected();

      printDebug("""
isConnected: $isConnected
""");

      expect(isConnected, isFalse);
      expect(File(coinsAESPath).existsSync(), isFalse);
      expect(File(coinsCacheAESPath).existsSync(), isFalse);
      expect(File(coinsListedAESPath).existsSync(), isFalse);
    });

    test('Test (getAppChecksum)', () async {
      String? appChecksum = WalletikaAPI.getAppChecksum();

      printDebug("""
appChecksum: $appChecksum
""");

      expect(appChecksum, isNull);
    });

    test('Test (getDefaultNetworks)', () async {
      List<Map<String, dynamic>>? defaultNetworks =
          WalletikaAPI.getDefaultNetworks();

      printDebug("""
defaultNetworks: $defaultNetworks
""");

      expect(defaultNetworks, isNull);
    });

    test('Test (getDefaultTokens)', () async {
      List<Map<String, dynamic>>? defaultTokens =
          WalletikaAPI.getDefaultTokens();

      printDebug("""
defaultTokens: $defaultTokens
""");

      expect(defaultTokens, isNull);
    });

    test('Test (getCoinsListed)', () async {
      List<Map<String, dynamic>>? coinsListed = WalletikaAPI.getCoinsListed();

      printDebug("""
coinsListed: $coinsListed
""");

      expect(coinsListed, isNull);
    });

    test('Test (getStakeContracts)', () async {
      List<Map<String, dynamic>>? stakeContracts =
          WalletikaAPI.getStakeContracts();

      printDebug("""
stakeContracts: $stakeContracts
""");

      expect(stakeContracts, isNull);
    });
  });

  group('Coins Prices Group:', () {
    test('Test (getCoinsPrices)', () async {
      List<String> symbols = ['BTC', 'ETH', 'BNB', 'MATIC'];
      List<CoinPrice> coins = await WalletikaAPI.getCoinsPrices(
        symbols.map((symbol) => CoinEntry(symbol: symbol)).toList(),
      );

      for (int i = 0; i < coins.length; i++) {
        CoinPrice coin = coins[i];

        printDebug("""
symbol: ${coin.symbol}
price: ${coin.price}
changeIn24h: ${coin.changeIn24h}
""");

        expect(coin.symbol, equals(symbols[i]));
        expect(coin.price, isNull);
        expect(coin.changeIn24h, isNull);
      }
    });

    test('Test (getCoinPrice) USDT by name', () async {
      CoinPrice coin = await WalletikaAPI.getCoinPrice(CoinEntry(
        symbol: 'USDT',
        name: 'Tether',
      ));

      printDebug("""
symbol: ${coin.symbol}
price: ${coin.price}
changeIn24h: ${coin.changeIn24h}
""");

      expect(coin.symbol, equals('USDT'));
      expect(coin.price, isNull);
      expect(coin.changeIn24h, isNull);
    });

    test('Test (getCoinPrice) USDT by name and contract address', () async {
      CoinPrice coin = await WalletikaAPI.getCoinPrice(CoinEntry(
        symbol: 'USDT',
        name: 'Tether',
        contractAddress:
            '0xc2132d05d31c914a87c6611c10748aeb04b58e8f', // polygon network,
      ));

      printDebug("""
symbol: ${coin.symbol}
price: ${coin.price}
changeIn24h: ${coin.changeIn24h}
""");

      expect(coin.symbol, equals('USDT'));
      expect(coin.price, isNull);
      expect(coin.changeIn24h, isNull);
    });

    test('Test (getCoinPrice) USDT by wrong name', () async {
      CoinPrice coin = await WalletikaAPI.getCoinPrice(CoinEntry(
        symbol: 'USDT',
        name: 'AnyName',
      ));

      printDebug("""
symbol: ${coin.symbol}
price: ${coin.price}
changeIn24h: ${coin.changeIn24h}
""");

      expect(coin.symbol, equals('USDT'));
      expect(coin.price, isNull);
      expect(coin.changeIn24h, isNull);
    });

    test('Test (getCoinPrice) for WTK', () async {
      CoinPrice coin = await WalletikaAPI.getCoinPrice(CoinEntry(
        symbol: 'WTK',
        name: 'Walletika',
        contractAddress: '0xc4d3716B65b9c4c6b69e4E260b37e0e476e28d87',
      ));

      printDebug("""
symbol: ${coin.symbol}
price: ${coin.price}
changeIn24h: ${coin.changeIn24h}
""");

      expect(coin.symbol, equals('WTK'));
      expect(coin.price, isNull);
      expect(coin.changeIn24h, isNull);
    });
  });

  group('Coins Images Group:', () {
    test('Test (getCoinsImages)', () async {
      List<String> images = [
        'https://etherscan.io/images/main/empty-token.png',
        'https://etherscan.io/images/main/empty-token.png',
        'https://etherscan.io/images/main/empty-token.png',
      ];
      List<String> symbols = ['ETH', 'BNB', 'MATIC'];
      List<CoinImage> coins = await WalletikaAPI.getCoinsImages(
        symbols.map((symbol) => CoinEntry(symbol: symbol)).toList(),
      );

      for (int i = 0; i < coins.length; i++) {
        CoinImage coin = coins[i];

        printDebug("""
symbol: ${coin.symbol}
imageURL: ${coin.imageURL}
""");

        expect(coin.symbol, equals(symbols[i]));
        expect(coin.imageURL, equals(images[i]));
      }
    });

    test('Test (getCoinImage) USDT by name', () async {
      CoinImage coin = await WalletikaAPI.getCoinImage(CoinEntry(
        symbol: 'USDT',
        name: 'Tether',
      ));

      printDebug("""
symbol: ${coin.symbol}
imageURL: ${coin.imageURL}
""");

      expect(coin.symbol, equals('USDT'));
      expect(
        coin.imageURL,
        equals('https://etherscan.io/images/main/empty-token.png'),
      );
    });

    test('Test (getCoinImage) USDT by name and contract address', () async {
      CoinImage coin = await WalletikaAPI.getCoinImage(CoinEntry(
        symbol: 'USDT',
        name: 'Tether',
        contractAddress:
            '0xc2132d05d31c914a87c6611c10748aeb04b58e8f', // polygon network,
      ));

      printDebug("""
symbol: ${coin.symbol}
imageURL: ${coin.imageURL}
""");

      expect(coin.symbol, equals('USDT'));
      expect(
        coin.imageURL,
        equals('https://etherscan.io/images/main/empty-token.png'),
      );
    });

    test('Test (getCoinImage) USDT by wrong name', () async {
      CoinImage coin = await WalletikaAPI.getCoinImage(CoinEntry(
        symbol: 'USDT',
        name: 'AnyName',
      ));

      printDebug("""
symbol: ${coin.symbol}
imageURL: ${coin.imageURL}
""");

      expect(coin.symbol, equals('USDT'));
      expect(
        coin.imageURL,
        equals('https://etherscan.io/images/main/empty-token.png'),
      );
    });

    test('Test (getCoinImage) for WTK', () async {
      CoinImage coin = await WalletikaAPI.getCoinImage(CoinEntry(
        symbol: 'WTK',
        name: 'Walletika',
        contractAddress: '0xc4d3716B65b9c4c6b69e4E260b37e0e476e28d87',
      ));

      printDebug("""
symbol: ${coin.symbol}
imageURL: ${coin.imageURL}
""");

      expect(coin.symbol, equals('WTK'));
      expect(
        coin.imageURL,
        equals('https://etherscan.io/images/main/empty-token.png'),
      );
    });
  });
}
