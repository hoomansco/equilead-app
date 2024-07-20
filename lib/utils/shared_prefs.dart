import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? _sharedPreferences;
  factory SharedPrefs() => SharedPrefs._internal();
  SharedPrefs._internal();
  Future<void> init() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  Future<void> setAccessToken(String token) async {
    await _sharedPreferences!.setString("token", token);
  }

  String getAccessToken() {
    return _sharedPreferences!.getString("token") ?? "";
  }

  Future<void> setRefreshToken(String token) async {
    await _sharedPreferences!.setString("refreshToken", token);
  }

  String getRefreshToken() {
    return _sharedPreferences!.getString("refreshToken") ?? "";
  }

  Future<void> setPhoneNumber(String number) async {
    await _sharedPreferences!.setString("phone", number);
  }

  String getPhoneNumber() {
    return _sharedPreferences!.getString("phone") ?? "";
  }

  Future<void> setUserID(String userId) async {
    await _sharedPreferences!.setString("userID", userId);
  }

  String getUserID() {
    return _sharedPreferences!.getString("userID") ?? "";
  }

  void setMemberID(String memberId) async {
    await _sharedPreferences!.setString("memberID", memberId);
  }

  String getMemberID() {
    return _sharedPreferences!.getString("memberID") ?? "";
  }

  Future<void> setStudentStatus(bool isStudent) async {
    await _sharedPreferences!.setBool("isStudent", isStudent);
  }

  bool getStudentStatus() {
    return _sharedPreferences!.getBool("isStudent") ?? false;
  }

  Future logout() async {
    await _sharedPreferences!.remove("token");
    await _sharedPreferences!.remove("refreshToken");
    await _sharedPreferences?.remove("phone");
    await _sharedPreferences?.remove("userID");
    await _sharedPreferences?.remove("memberID");
    await _sharedPreferences?.remove("isStudent");
  }
}
