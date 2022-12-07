import 'dart:io';

import 'package:aescrypto/aescrypto.dart';
import 'package:walletika_api/src/core/core.dart';
import 'package:walletika_api/walletika_api.dart';
import 'package:test/test.dart';

const debugging = true;
void printDebug(String message) {
  if (debugging) print(message);
}

void main() async {
  const String wtkImage =
      'https://raw.githubusercontent.com/Walletika/metadata/main/walletika.png';
  final String coinsFilePath = addAESExtension(coinsPath);
  final String coinsCacheFilePath = addAESExtension(coinsCachePath);
  final WalletikaAPI walletikaAPI = WalletikaAPI(
    '123456',
    walletikaImage: wtkImage,
  );

  group('Walletika API Offline Group:', () {
    test('Test (load & update & ping)', () async {
      await walletikaAPI.load();

      printDebug("""
isConnected: ${walletikaAPI.isConnected}
""");

      expect(walletikaAPI.isConnected, isFalse);
      expect(File(coinsFilePath).existsSync(), isFalse);
      expect(File(coinsCacheFilePath).existsSync(), isFalse);
    });
  });

  group('Coins Prices Group:', () {
    test('Test (getCoinsPrices)', () async {
      List<String> symbols = ['BTC', 'ETH', 'BNB', 'MATIC'];
      List<CoinPrice> coins = await walletikaAPI.getCoinsPrices(
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
      CoinPrice coin = await walletikaAPI.getCoinPrice(CoinEntry(
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
      CoinPrice coin = await walletikaAPI.getCoinPrice(CoinEntry(
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
      CoinPrice coin = await walletikaAPI.getCoinPrice(CoinEntry(
        symbol: 'USDT',
        name: 'Anyname',
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
  });

  group('Coins Images Group:', () {
    test('Test (getCoinsImages)', () async {
      List<String> images = [
        'https://etherscan.io/images/main/empty-token.png',
        'https://etherscan.io/images/main/empty-token.png',
        'https://etherscan.io/images/main/empty-token.png',
      ];
      List<String> symbols = ['ETH', 'BNB', 'MATIC'];
      List<CoinImage> coins = await walletikaAPI.getCoinsImages(
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
      CoinImage coin = await walletikaAPI.getCoinImage(CoinEntry(
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
      CoinImage coin = await walletikaAPI.getCoinImage(CoinEntry(
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
      CoinImage coin = await walletikaAPI.getCoinImage(CoinEntry(
        symbol: 'USDT',
        name: 'Anyname',
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
      CoinImage coin = await walletikaAPI.getCoinImage(CoinEntry(
        symbol: 'WTK',
        name: 'Walletika',
      ));

      printDebug("""
symbol: ${coin.symbol}
imageURL: ${coin.imageURL}
""");

      expect(coin.symbol, equals('WTK'));
      expect(coin.imageURL, equals(wtkImage));
    });
  });
}
