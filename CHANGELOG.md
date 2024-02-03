## 3.0.2
- Upgrade getCoinID method to check as a coin and token
- Always check the coin prices and images in offline

## 3.0.1
- Use GPL-3.0 license
- Use http package version 0.13.6
- Cache validator
- Don't fetch listed networks images

## 3.0.0
- Upgrade cache system.
- Package infrastructure improvement
- Added logs
- Added `isInitialized` method
- Added `id` property to `CoinEntry`
- Added `checkCache` argument to `getCoinsPrices`, `getCoinsImages`, `getCoinPrice` and `getCoinImage`
- Removed `changeIn24h` argument to `getCoinsPrices`, `getCoinsImages`, `getCoinPrice` and `getCoinImage`
- Removed `setDefaultCoinURLImage` method
- Renamed `getAppChecksum` method to `version`
- Renamed `getDefaultNetworks` method to `listedNetworks`
- Renamed `getDefaultTokens` method to `listedCoins`
- Renamed `getCoinsListed` method to `offlineCoins`
- Renamed `getStakeContracts` method to `listedStakes`
- Nullable `imageURL` for `CoinImage`
- Show values of `CoinEntry`, `CoinPrice` and `CoinImage` with `toString` method
