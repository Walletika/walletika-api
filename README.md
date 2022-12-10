# Walletika API
### Get coins details like prices and images from API
- Designed by: Walletika Team

## Usage
### Initialization
```dart
import 'package:walletika_api/walletika_api.dart';

// WalletikaAPI initialize
await WalletikaAPI.init('key');

// Download latest update from CoinGecko
await WalletikaAPI.update();

// Check connection
await WalletikaAPI.isConnected();

// Set defailt coin image if not found
WalletikaAPI.setDefaultCoinURLImage(
  'https://etherscan.io/images/main/empty-token.png',
);
```

### Use `getCoinPrice` function to get coin price
```dart
import 'package:walletika_api/walletika_api.dart';

// Get coin price
// CoinEntry symbol is required, You can more filter by address and name
CoinPrice coinPrice = await WalletikaAPI.getCoinPrice(CoinEntry(
  symbol: 'USDT',
  name: 'Tether',
  contractAddress: '0xc2132d05d31c914a87c6611c10748aeb04b58e8f',
));
// Coin details
String symbol = coin.symbol;
double price = coin.price;
double changeIn24h = coin.changeIn24h;
```

### Use `getCoinImage` function to get coin image
```dart
import 'package:walletika_api/walletika_api.dart';

// Get coin images
// CoinEntry symbol is required, You can more filter by address and name
CoinImage coinImage = await WalletikaAPI.getCoinImage(CoinEntry(
  symbol: 'USDT',
  name: 'Tether',
  contractAddress: '0xc2132d05d31c914a87c6611c10748aeb04b58e8f',
));
// Coin details
String symbol = coin.symbol;
String image = coin.imageURL;
```
