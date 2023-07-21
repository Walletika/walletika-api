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
