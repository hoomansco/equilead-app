import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equilead/models/auth.dart';
import 'package:equilead/models/user.dart';
import 'package:equilead/utils/shared_prefs.dart';

class AuthNotifier extends StateNotifier<Auth> {
  AuthNotifier() : super(Auth(isLoggedIn: false, user: User()));

  Future<void> login(User user, String accessToken, String refreshToken) async {
    state = Auth(isLoggedIn: true, user: user);
    await SharedPrefs().setUserID(user.id!);
    await SharedPrefs().setPhoneNumber(user.phone!);
    await SharedPrefs().setAccessToken(accessToken);
    await SharedPrefs().setRefreshToken(refreshToken);
  }

  void logout() async {
    state = Auth(isLoggedIn: false, user: User());
    await SharedPrefs().logout();
  }

  void checkLogin() {
    var userId = SharedPrefs().getUserID();
    var phone = SharedPrefs().getPhoneNumber();

    if (userId.isNotEmpty && phone.isNotEmpty) {
      state = Auth(isLoggedIn: true, user: User(id: userId, phone: phone));
    }
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, Auth>((ref) => AuthNotifier());
