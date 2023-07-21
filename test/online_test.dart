import 'dart:convert';
import 'dart:io';

import 'package:walletika_api/walletika_api.dart';
import 'package:test/test.dart';

const debugging = true;
void printDebug(String message) {
  if (debugging) print(message);
}

void main() async {
  const String api =
      'https://raw.githubusercontent.com/Walletika/walletika-api/main/test/data.json';
  const String wtkImage =
      'https://raw.githubusercontent.com/Walletika/metadata/main/coins/walletika.png';

  group('Walletika API Online Group:', () {
    late FetchResult fetchResult;

    setUpAll(() async {
      fetchResult = FetchResult.fromJson(
        jsonDecode(await File('test/data.json').readAsString()),
      );
    });

    test('Test (init)', () async {
      await WalletikaAPI.init(
        encryptionKey: 'key',
        apiURL: api,
        apiDecryptionKey: 'key',
      );
      bool isConnected = await WalletikaAPI.isConnected();

      printDebug("""
isConnected: $isConnected
""");

      expect(isConnected, isTrue);
    });

    test('Test (version)', () async {
      String? version = WalletikaAPI.version;

      printDebug("""
version: $version
""");

      expect(version, equals(fetchResult.version));
    });

    test('Test (listedNetworks)', () async {
      List<Map<String, dynamic>>? listedNetworks = WalletikaAPI.listedNetworks;

      printDebug("""
listedNetworks: $listedNetworks
""");

      expect(listedNetworks, equals(fetchResult.listedNetworks));
    });

    test('Test (listedCoins)', () async {
      List<Map<String, dynamic>>? listedCoins = WalletikaAPI.listedCoins;

      printDebug("""
listedCoins: $listedCoins
""");

      expect(listedCoins, equals(fetchResult.listedCoins));
    });

    test('Test (offlineCoins)', () async {
      List<Map<String, dynamic>>? offlineCoins = WalletikaAPI.offlineCoins;

      printDebug("""
offlineCoins: $offlineCoins
""");

      expect(offlineCoins, equals(fetchResult.offlineCoins));
    });

    test('Test (listedStakes)', () async {
      List<Map<String, dynamic>>? listedStakes = WalletikaAPI.listedStakes;

      printDebug("""
listedStakes: $listedStakes
""");

      expect(listedStakes, equals(fetchResult.listedStakes));
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
        expect(coin.price, isNotNull);
        expect(coin.changeIn24h, isNotNull);
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
      expect(coin.price, isNotNull);
      expect(coin.changeIn24h, isNotNull);
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
      expect(coin.price, isNotNull);
      expect(coin.changeIn24h, isNotNull);
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
      expect(coin.price, equals(0.02));
      expect(coin.changeIn24h, isNull);
    });
  });

  group('Coins Images Group:', () {
    test('Test (getCoinsImages)', () async {
      List<String> images = [
        'https://assets.coingecko.com/coins/images/279/small/ethereum.png?1595348880',
        'https://assets.coingecko.com/coins/images/825/small/bnb-icon2_2x.png?1644979850',
        'https://assets.coingecko.com/coins/images/4713/small/matic-token-icon.png?1624446912',
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
          equals(
            'https://assets.coingecko.com/coins/images/325/small/Tether.png?1668148663',
          ));
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
          equals(
            'https://assets.coingecko.com/coins/images/325/small/Tether.png?1668148663',
          ));
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
      expect(coin.imageURL, isNull);
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
      expect(coin.imageURL, equals(wtkImage));
    });
  });
}
