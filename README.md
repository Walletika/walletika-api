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
  apiURL: 'https://github.com/Walletika/metadata/raw/main/app_info_test.json',
);

// Download latest update from CoinGecko
await WalletikaAPI.update();

// Check connection
await WalletikaAPI.isConnected();

// Get application checksum from API
String? appChecksum = WalletikaAPI.getAppChecksum();

// Get default networks from API
List<Map<String, dynamic>>? defaultNetworks = WalletikaAPI.getDefaultNetworks();

// Get default tokens from API
List<Map<String, dynamic>>? defaultTokens = WalletikaAPI.getDefaultTokens();

// Get coins are listed from API
List<Map<String, dynamic>>? coinsListed = WalletikaAPI.getCoinsListed();

// Get stake contracts from API
List<Map<String, dynamic>>? stakeContracts = WalletikaAPI.getStakeContracts();

// Set default coin image if not found
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
