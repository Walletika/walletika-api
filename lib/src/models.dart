class CoinEntry {
  final String symbol;
  final String? name;
  final String? contractAddress;

  CoinEntry({
    required this.symbol,
    this.name,
    this.contractAddress,
  });
}

class CoinPrice {
  final String symbol;
  final String? contractAddress;
  final double? price;
  final double? changeIn24h;

  CoinPrice({
    required this.symbol,
    this.contractAddress,
    this.price,
    this.changeIn24h,
  });
}

class CoinImage {
  final String symbol;
  final String? contractAddress;
  final String imageURL;

  CoinImage({
    required this.symbol,
    this.contractAddress,
    required this.imageURL,
  });
}
