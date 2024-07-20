import 'dart:convert';

class User {
  String? id;
  String? phone;

  User({this.id, this.phone});

  User.fromRawJson(String str) {
    Map<String, dynamic> json = jsonDecode(str);
    id = json['id'].toString();
    phone = json['phoneNumber'];
  }

  User.fromJson(Map<String, dynamic>? json) {
    id = json?['id'];
    phone = json?['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['phoneNumber'] = phone;
    return data;
  }
}
