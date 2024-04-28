import 'package:walletika_api/walletika_api.dart';
import 'package:test/test.dart';

const debugging = true;
void printDebug(String message) {
  if (debugging) print(message);
}

void main() async {
  const String api =
      'https://raw.githubusercontent.com/Walletika/walletika-api/main/test/data.json';

  group('Walletika API Offline Group:', () {
    test('Test (init)', () async {
      await WalletikaAPI.init(encryptionKey: 'key', apiURL: api);
      bool isConnected = await WalletikaAPI.isConnected();

      printDebug("""
isConnected: $isConnected
""");

      expect(isConnected, isFalse);
    });

    test('Test (version)', () async {
      String? version = WalletikaAPI.version;

      printDebug("""
version: $version
""");

      expect(version, isNull);
    });

    test('Test (listCoinsAPI)', () async {
      String? listCoinsAPI = WalletikaAPI.listCoinsAPI;

      printDebug("""
listCoinsAPI: $listCoinsAPI
""");

      expect(listCoinsAPI, isNull);
    });

    test('Test (listedNetworks)', () async {
      List<Map<String, dynamic>>? listedNetworks = WalletikaAPI.listedNetworks;

      printDebug("""
listedNetworks: $listedNetworks
""");

      expect(listedNetworks, isNull);
    });

    test('Test (listedCoins)', () async {
      List<Map<String, dynamic>>? listedCoins = WalletikaAPI.listedCoins;

      printDebug("""
listedCoins: $listedCoins
""");

      expect(listedCoins, isNull);
    });

    test('Test (offlineCoins)', () async {
      List<Map<String, dynamic>>? offlineCoins = WalletikaAPI.offlineCoins;

      printDebug("""
offlineCoins: $offlineCoins
""");

      expect(offlineCoins, isNull);
    });

    test('Test (listedStakes)', () async {
      List<Map<String, dynamic>>? listedStakes = WalletikaAPI.listedStakes;

      printDebug("""
listedStakes: $listedStakes
""");

      expect(listedStakes, isNull);
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
        expect(coin.imageURL, isNull);
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
      expect(coin.imageURL, isNull);
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
      expect(coin.imageURL, isNull);
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
      expect(coin.imageURL, isNull);
    });
  });
}
