# Walletika API
### Get coins details like prices and images from API
- Designed by: Walletika Team

## Usage
### Initialization
```dart
import 'package:walletika_api/walletika_api.dart';

// WalletikaAPI initialize
await WalletikaAPI.init(
  encryptionKey: 'key',
  apiURL: 'https://raw.githubusercontent.com/Walletika/walletika-api/main/test/data.json',
);

// Download latest update from CoinGecko, it will call automatically with initialization
await WalletikaAPI.update();

// Check the internet connection
await WalletikaAPI.isConnected();

// Get application version from API
String? version = WalletikaAPI.version;

// Get listCoinsAPI URL from API
String? listCoinsAPI = WalletikaAPI.listCoinsAPI;

// Get listed networks from API
List<Map<String, dynamic>>? listedNetworks = WalletikaAPI.listedNetworks;

// Get listed coins from API
List<Map<String, dynamic>>? listedCoins = WalletikaAPI.listedCoins;

// Get offline coins from API
List<Map<String, dynamic>>? offlineCoins = WalletikaAPI.offlineCoins;

// Get listed stakes from API
List<Map<String, dynamic>>? listedStakes = WalletikaAPI.listedStakes;
```

### Use `getCoinPrice` function to get coin price
```dart
import 'package:walletika_api/walletika_api.dart';

// Get list of coins prices
// CoinEntry symbol is required, You can more filter by address and name
CoinPrice coinPrice = await WalletikaAPI.getCoinPrice(CoinEntry(
  symbol: 'USDT',
  name: 'Tether',
  contractAddress: '0xc2132d05d31c914a87c6611c10748aeb04b58e8f',
));
// Coin details
String symbol = coin.symbol;
double? price = coin.price;
double? changeIn24h = coin.changeIn24h;
```

### Use `getCoinImage` function to get coin image
```dart
import 'package:walletika_api/walletika_api.dart';

// Get list of coins images
// CoinEntry symbol is required, You can more filter by address and name
CoinImage coinImage = await WalletikaAPI.getCoinImage(CoinEntry(
  symbol: 'USDT',
  name: 'Tether',
  contractAddress: '0xc2132d05d31c914a87c6611c10748aeb04b58e8f',
));
// Coin details
String symbol = coin.symbol;
String? image = coin.imageURL;
```
