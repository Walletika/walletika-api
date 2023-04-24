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

class CoinListed {
  final String name;
  final String symbol;
  final List<dynamic> contracts;
  final double price;
  final String imageURL;

  CoinListed({
    required this.name,
    required this.symbol,
    required this.contracts,
    required this.price,
    required this.imageURL,
  });

  factory CoinListed.fromJson(Map<String, dynamic> json) => CoinListed(
        name: json["name"],
        symbol: json["symbol"],
        contracts: json["contracts"],
        price: json["price"],
        imageURL: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "symbol": symbol,
        "contracts": contracts,
        "price": price,
        "image": imageURL,
      };
}

class FetchResult {
  final String? appChecksum;
  final List<Map<String, dynamic>>? defaultNetworks;
  final List<Map<String, dynamic>>? defaultTokens;
  final List<Map<String, dynamic>>? coinsListed;
  final List<Map<String, dynamic>>? stakeContracts;

  FetchResult({
    this.appChecksum,
    this.defaultNetworks,
    this.defaultTokens,
    this.coinsListed,
    this.stakeContracts,
  });

  factory FetchResult.fromJson(Map<String, dynamic> json) => FetchResult(
        appChecksum: json["appChecksum"],
        defaultNetworks: json["defaultNetworks"]?.cast<Map<String, dynamic>>(),
        defaultTokens: json["defaultTokens"]?.cast<Map<String, dynamic>>(),
        coinsListed: json["coinsListed"]?.cast<Map<String, dynamic>>(),
        stakeContracts: json["stakeContracts"]?.cast<Map<String, dynamic>>(),
      );

  Map<String, dynamic> toJson() => {
        "appChecksum": appChecksum,
        "defaultNetworks": defaultNetworks,
        "defaultTokens": defaultTokens,
        "coinsListed": coinsListed,
        "stakeContracts": stakeContracts,
      };
}
