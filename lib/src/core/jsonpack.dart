import 'dart:convert';
import 'dart:typed_data';

Uint8List jsonEncodeToBytes(Object data) {
  return utf8.encoder.convert(jsonEncode(data));
}

dynamic jsonDecodeFromBytes(Uint8List data) {
  return jsonDecode(utf8.decoder.convert(data));
}
