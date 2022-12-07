import 'package:walletika_api/walletika_api.dart';

void main() async {
  // Create new object of WalletikaAPI
  WalletikaAPI walletikaAPI = WalletikaAPI('key');

  // Load coins data
  await walletikaAPI.load();

  // Download latest update of CoinGecko
  await walletikaAPI.update();

  // Send ping package
  await walletikaAPI.ping();

  // Check connection
  walletikaAPI.isConnected;

  // Set defailt coin image if not found
  walletikaAPI.setDefaultCoinURLImage(
    'https://etherscan.io/images/main/empty-token.png',
  );

  // Get list of coins prices
  // CoinEntry symbol is required, You can more filter by address and name
  List<CoinPrice> coinsPrices = await walletikaAPI.getCoinsPrices([
    CoinEntry(symbol: 'BTC'),
    CoinEntry(symbol: 'ETH'),
    CoinEntry(symbol: 'USDT'),
  ]);

  // Get coin price
  // CoinEntry symbol is required, You can more filter by address and name
  CoinPrice coinPrice = await walletikaAPI.getCoinPrice(CoinEntry(
    symbol: 'USDT',
    name: 'Tether',
    contractAddress: '0xc2132d05d31c914a87c6611c10748aeb04b58e8f',
  ));

  // Get list of coins images
  // CoinEntry symbol is required, You can more filter by address and name
  List<CoinImage> coinsImages = await walletikaAPI.getCoinsImages([
    CoinEntry(symbol: 'BTC'),
    CoinEntry(symbol: 'ETH'),
    CoinEntry(symbol: 'USDT'),
  ]);

  // Get coin images
  // CoinEntry symbol is required, You can more filter by address and name
  CoinImage coinImage = await walletikaAPI.getCoinImage(CoinEntry(
    symbol: 'USDT',
    name: 'Tether',
    contractAddress: '0xc2132d05d31c914a87c6611c10748aeb04b58e8f',
  ));
}
