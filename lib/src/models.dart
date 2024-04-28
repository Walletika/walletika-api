import 'core/core.dart';

class CoinEntry {
  final String symbol;
  final String? name;
  final String? contractAddress;

  CoinEntry({
    required this.symbol,
    this.name,
    this.contractAddress,
  });

  String? get id => getCoinID(this);

  @override
  bool operator ==(Object other) {
    if (other is CoinEntry) {
      return symbol == other.symbol &&
          name == other.name &&
          contractAddress == other.contractAddress;
    }

    return false;
  }

  @override
  String toString() {
    return "CoinImage(id: $id, symbol: $symbol, contractAddress: $contractAddress, name: $name)";
  }
}

class CoinPrice {
  final String? id;
  final String symbol;
  final String? contractAddress;
  final double? price;
  final double? changeIn24h;

  CoinPrice({
    required this.id,
    required this.symbol,
    this.contractAddress,
    this.price,
    this.changeIn24h,
  });

  @override
  String toString() {
    return "CoinPrice(id: $id, symbol: $symbol, contractAddress: $contractAddress, price: $price, changeIn24h: $changeIn24h)";
  }
}

class CoinImage {
  final String? id;
  final String symbol;
  final String? contractAddress;
  final String? imageURL;

  CoinImage({
    required this.id,
    required this.symbol,
    this.contractAddress,
    this.imageURL,
  });

  @override
  String toString() {
    return "CoinImage(id: $id, symbol: $symbol, contractAddress: $contractAddress, imageURL: $imageURL)";
  }
}

class OfflineCoin {
  final String name;
  final String symbol;
  final List<String> contracts;
  final double price;
  final String imageURL;

  OfflineCoin({
    required this.name,
    required this.symbol,
    required this.contracts,
    required this.price,
    required this.imageURL,
  });

  factory OfflineCoin.fromJson(Map<String, dynamic> json) => OfflineCoin(
        name: json[EKey.name],
        symbol: json[EKey.symbol],
        contracts: json[EKey.contracts].cast<String>(),
        price: json[EKey.price],
        imageURL: json[EKey.image],
      );

  Map<String, dynamic> toJson() => {
        EKey.name: name,
        EKey.symbol: symbol,
        EKey.contracts: contracts,
        EKey.price: price,
        EKey.image: imageURL,
      };
}

class FetchResult {
  final String? version;
  final List<Map<String, dynamic>>? listedNetworks;
  final List<Map<String, dynamic>>? listedCoins;
  final List<Map<String, dynamic>>? offlineCoins;
  final List<Map<String, dynamic>>? listedStakes;

  FetchResult({
    this.version,
    this.listedNetworks,
    this.listedCoins,
    this.offlineCoins,
    this.listedStakes,
  });

  factory FetchResult.fromJson(Map<String, dynamic> json) => FetchResult(
        version: json[EKey.version],
        listedNetworks: json[EKey.listedNetworks]?.cast<Map<String, dynamic>>(),
        listedCoins: json[EKey.listedCoins]?.cast<Map<String, dynamic>>(),
        offlineCoins: json[EKey.offlineCoins]?.cast<Map<String, dynamic>>(),
        listedStakes: json[EKey.listedStakes]?.cast<Map<String, dynamic>>(),
      );

  Map<String, dynamic> toJson() => {
        EKey.version: version,
        EKey.listedNetworks: listedNetworks,
        EKey.listedCoins: listedCoins,
        EKey.offlineCoins: offlineCoins,
        EKey.listedStakes: listedStakes,
      };
}
