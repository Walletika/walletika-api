import 'dart:convert';
import 'dart:typed_data';

/// Convert json data to bytes `Uint8List`
Uint8List jsonEncodeToBytes(Object data) {
  return utf8.encoder.convert(jsonEncode(data));
}

/// Convert data bytes `Uint8List` to json object
dynamic jsonDecodeFromBytes(Uint8List data) {
  return jsonDecode(utf8.decoder.convert(data));
}
