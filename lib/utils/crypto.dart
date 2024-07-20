import 'dart:convert';

import 'package:crypto/crypto.dart';

class CryptoUtil {
  static String hashPhoneNumber(String phone) {
    var bytes = utf8.encode(phone);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}
