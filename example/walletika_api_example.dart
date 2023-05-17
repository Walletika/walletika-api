import 'package:walletika_api/walletika_api.dart';

void main() async {
  // WalletikaAPI initialize
  await WalletikaAPI.init(
    encryptionKey: 'key',
    apiURL: 'https://github.com/Walletika/metadata/raw/main/app_info_test.json',
  );

  // Download latest update from CoinGecko
  await WalletikaAPI.update();

  // Check connection
  await WalletikaAPI.isConnected();

  // Set default coin image if not found
  WalletikaAPI.setDefaultCoinURLImage(
    'https://etherscan.io/images/main/empty-token.png',
  );

  // Get list of coins prices
  // CoinEntry symbol is required, You can more filter by address and name
  await WalletikaAPI.getCoinsPrices([
    CoinEntry(symbol: 'BTC'),
    CoinEntry(symbol: 'ETH'),
    CoinEntry(symbol: 'USDT'),
  ]);

  // Get coin price
  // CoinEntry symbol is required, You can more filter by address and name
  await WalletikaAPI.getCoinPrice(CoinEntry(
    symbol: 'USDT',
    name: 'Tether',
    contractAddress: '0xc2132d05d31c914a87c6611c10748aeb04b58e8f',
  ));

  // Get list of coins images
  // CoinEntry symbol is required, You can more filter by address and name
  await WalletikaAPI.getCoinsImages([
    CoinEntry(symbol: 'BTC'),
    CoinEntry(symbol: 'ETH'),
    CoinEntry(symbol: 'USDT'),
  ]);

  // Get coin images
  // CoinEntry symbol is required, You can more filter by address and name
  await WalletikaAPI.getCoinImage(CoinEntry(
    symbol: 'USDT',
    name: 'Tether',
    contractAddress: '0xc2132d05d31c914a87c6611c10748aeb04b58e8f',
  ));
}
