import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:aescrypto/aescrypto.dart';
import 'package:http/http.dart' as http;

import '../models.dart';

Future<FetchResult> fetcher({
  required String apiURL,
  String? decryptionKey,
}) async {
  Map<String, dynamic> result = {};
  bool received = false;

  try {
    final http.Response response = await http.get(Uri.parse(apiURL));
    result = jsonDecode(response.body);
    received = true;
  } on SocketException {
    // Nothing to do
  }

  if (received && decryptionKey != null && result.length == 1) {
    final AESCrypto cipher = AESCrypto(key: decryptionKey);
    result = jsonDecode(
      await cipher.decryptText(
        bytes: Uint8List.fromList((result['data'] as List).cast<int>()),
        hasKey: true,
      ),
    );
  }

  return FetchResult.fromJson(result);
}
