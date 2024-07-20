import 'dart:convert';
import 'package:http/http.dart' as http;

class OTPService {
  final String _authKey = '232595A28Or0tLVhw65cf6fe2P1';
  final String _baseUrl = 'https://api.msg91.com/api/v5/otp';

  Future<bool> sendOTP(String mobileNumber, String countryCode) async {
    final response = await http.post(Uri.parse('$_baseUrl'), body: {
      'mobile': "${countryCode}${mobileNumber}",
      'template_id': "65df17bfd6fc056137359f72",
      "otp_expiry": "5",
    }, headers: {
      'accept': 'application/json',
      'authkey': _authKey,
    });

    var resp = jsonDecode(response.body);

    if (resp["type"] == "success") {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> verifyOTP(
      String mobileNumber, String countryCode, String otp) async {
    final response = await http.get(
        Uri.parse(
            '$_baseUrl/verify?otp=$otp&mobile=${countryCode}${mobileNumber}'),
        headers: {
          'accept': 'application/json',
          'authkey': _authKey,
        });
    var resp = jsonDecode(response.body);
    if (resp["type"] == "success") {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> resendOTP(String mobileNumber) async {
    final response = await http.post(Uri.parse('$_baseUrl'), body: {
      'mobile': "91$mobileNumber",
      'template_id': "65df17bfd6fc056137359f72",
      "otp_expiry": "5",
    }, headers: {
      'accept': 'application/json',
      'authkey': _authKey,
    });

    var resp = jsonDecode(response.body);

    if (resp["type"] == "success") {
      return true;
    } else {
      return false;
    }
  }
}
