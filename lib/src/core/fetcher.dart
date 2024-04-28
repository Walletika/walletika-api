import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:aescrypto/aescrypto.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';

Future<Map<String, dynamic>> fetcher({
  required String apiURL,
  String? decryptionKey,
}) async {
  Map<String, dynamic> result = {};

  try {
    final http.Response response = await http.get(Uri.parse(apiURL));
    result = jsonDecode(response.body);
  } on SocketException {
    // Nothing to do
  }

  if (decryptionKey != null && result.containsKey(EKey.data)) {
    final AESCrypto cipher = AESCrypto(key: decryptionKey);
    result = jsonDecode(
      await cipher.decryptText(
        bytes: Uint8List.fromList((result[EKey.data] as List).cast<int>()),
        hasKey: true,
      ),
    );
  }

  return result;
}
