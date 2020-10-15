import 'dart:convert';
import 'package:crypto/crypto.dart';

class CommonUtils {
  static String hash256String(String value) {
    var bytes = utf8.encode(value);
    var digest = sha256.convert(bytes);

    return digest.toString();
  }

  static bool equalsIgnoreCase(String string1, String string2) {
    return string1?.toLowerCase() == string2?.toLowerCase();
  }

  static bool hasKeyIgnoreCase(Map map, String key) {
    return map.keys.any((x) => equalsIgnoreCase(x, key));
  }

  static String convertToJson(dynamic object) {
    var encoder = JsonEncoder.withIndent('     ');
    return encoder.convert(object);
  }

  static Map<String, dynamic> convertFromJson(String jsonString) {
    return jsonString != null ? json.decode(jsonString) : null;
  }

  static String encodeMap(Map<String, String> data) {
    return data.keys.map((key) {
      var k = Uri.encodeComponent(key);
      var v = Uri.encodeComponent(data[key]);

      return "$k=$v";
    }).join('&');
  }

  static List<String> split(String string, String separator, {int max = 0}) {
    var result = new List<String>();

    if ((separator == null) || (separator.isEmpty)) {
      result.add(string);
      return result;
    }

    while (true) {
      var index = string.indexOf(separator, 0);

      if (index == -1 || (max > 0 && result.length >= max)) {
        result.add(string);
        break;
      }

      result.add(string.substring(0, index));
      string = string.substring(index + separator.length);
    }

    return result;
  }
}
