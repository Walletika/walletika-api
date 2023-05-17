import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:aescrypto/aescrypto.dart';

void main() async {
  const String encryptionKey = 'key';
  final Map<String, dynamic> jsonData = jsonDecode(
    await File('test/data.json').readAsString(),
  );

  final AESCrypto cipher = AESCrypto(key: encryptionKey);
  final Map<String, Uint8List> result = {
    "data": await cipher.encryptText(
      plainText: jsonEncode(jsonData),
      hasKey: true,
    )
  };

  print(jsonEncode(result));
}
