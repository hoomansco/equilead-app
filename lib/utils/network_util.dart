import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:equilead/constants.dart';
import 'shared_prefs.dart';

class NetworkUtils {
  // String url = "http://192.168.29.76:8080/";
  // String url = "http://localhost:8080/";
  static String url = 'https://equilead.hoomans.dev/';
  // String url = "http://192.168.1.43:8080/";
  //String url = "http://localhost:8080/";
  String token = "";
  String refreshToken = "";

  Future<http.Response?> httpGet(String api,
      {bool keyRequired = true, Map<String, String>? header}) async {
    try {
      var exactURL = url + api;
      var client = http.Client();

      if (keyRequired) {
        if (header == null) {
          if (token.isEmpty) {
            await iniToken();
          }
          if (token.isEmpty) {
            header = {"Content-Type": "application/json"};
          } else {
            header = {
              "Authorization": '$token',
              "Content-Type": "application/json",
            };
          }
        }
      }
      http.Response response =
          await client.get(Uri.parse(exactURL), headers: header);

      if (response.statusCode == 401) {
        log("NETWORK UTILS" + response.body);
        if (refreshToken.isEmpty) {
          await iniToken();
        }
        if (refreshToken.isNotEmpty) {
          var phoneNumber = SharedPrefs().getPhoneNumber();
          var refreshResponse = await client.post(
            Uri.parse(url + "auth/refresh"),
            headers: {
              "Authorization": '$refreshToken',
              "Content-Type": "application/json"
            },
            body: jsonEncode({
              "phoneNumber": "$phoneNumber",
            }),
          );
          if (refreshResponse.statusCode == 200) {
            var data = jsonDecode(refreshResponse.body);
            token = data['token'];
            refreshToken = data['refreshToken'];
            await SharedPrefs().setAccessToken(token);
            await SharedPrefs().setRefreshToken(refreshToken);
            header!['Authorization'] = '$token';
            response = await client.get(Uri.parse(exactURL), headers: header);
          }
        }
      }

      return response;
    } catch (e) {
      return null;
    }
  }

  Future<http.Response?> httpPost(String api, Map body,
      {Map<String, String>? header, bool keyRequired = true}) async {
    try {
      var exactURL = url + api;
      var client = http.Client();

      if (header == null) {
        header = {'Content-Type': 'application/json'};
      } else if (!header.containsKey('Content-Type')) {
        header['Content-Type'] = 'application/json';
      }
      if (keyRequired && !header.containsKey('Authorization')) {
        if (token.isEmpty) {
          await iniToken();
        }
        header['Authorization'] = '$token';
      }

      http.Response response = await client.post(
        Uri.parse(exactURL),
        headers: header,
        body: jsonEncode(body),
      );

      if (response.statusCode == 401) {
        log("NETWORK UTILS" + response.body);
        if (refreshToken.isEmpty) {
          await iniToken();
        }
        if (refreshToken.isNotEmpty) {
          log(refreshToken);
          var phoneNumber = SharedPrefs().getPhoneNumber();
          var refreshResponse = await client.post(
            Uri.parse(url + "auth/refresh"),
            headers: {
              "Authorization": '$refreshToken',
            },
            body: jsonEncode({
              "phoneNumber": "$phoneNumber",
            }),
          );
          print(refreshResponse.statusCode);
          if (refreshResponse.statusCode == 200) {
            var data = jsonDecode(refreshResponse.body);
            token = data['token'];
            refreshToken = data['refreshToken'];
            await SharedPrefs().setAccessToken(token);
            await SharedPrefs().setRefreshToken(refreshToken);
            header['Authorization'] = '$token';
            response = await client.post(
              Uri.parse(exactURL),
              headers: header,
              body: jsonEncode(body),
            );
          }
        }
      }

      return response;
    } catch (e) {
      return null;
    }
  }

  Future<http.Response?> httpDelete(String api, Map body,
      {Map<String, String>? header, bool keyRequired = true}) async {
    try {
      var exactURL = url + api;
      var client = http.Client();

      if (header == null) {
        header = {'Content-Type': 'application/x-www-form-urlencoded'};
      } else if (!header.containsKey('Content-Type')) {
        header['Content-Type'] = 'application/x-www-form-urlencoded';
      }
      if (keyRequired && !header.containsKey('Authorization')) {
        if (token.isEmpty) {
          await iniToken();
        }

        header['Authorization'] = '$token';
      }

      http.Response response = await client.delete(
        Uri.parse(exactURL),
        headers: header,
      );

      return response;
    } catch (e) {
      return null;
    }
  }

  Future<http.Response?> httpPut(String api, Map body,
      {Map<String, String>? header, bool keyRequired = true}) async {
    try {
      var exactURL = url + api;
      var client = http.Client();

      if (header == null) {
        header = {'Content-Type': 'application/json'};
      } else if (!header.containsKey('Content-Type')) {
        header['Content-Type'] = 'application/json';
      }
      if (keyRequired && !header.containsKey('Authorization')) {
        if (token.isEmpty) {
          await iniToken();
        }
        header['Authorization'] = '$token';
      }

      http.Response response = await client.put(
        Uri.parse(exactURL),
        headers: header,
        body: json.encode(body),
      );

      return response;
    } catch (e) {
      return null;
    }
  }

  Future iniToken() async {
    token = SharedPrefs().getAccessToken();
    refreshToken = SharedPrefs().getRefreshToken();
  }

  Future uploadImageToS3(File image) async {
    // API Endpoint URL (Replace with your Go API's endpoint)
    final apiUrl = url + 'aws/s3/upload';

    // Create multipart request
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    if (token.isEmpty) {
      await iniToken();
    }

    request.headers.addAll({
      'Authorization': token,
    });

    // Add the image file
    var multipartFile = await http.MultipartFile.fromPath('image', image.path);
    request.files.add(multipartFile);

    // Send the request
    var response = await request.send();

    // Handle the response
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      log('Image uploaded successfully: $responseBody');
      return responseBody;
    } else {
      throw Exception(
          'Image upload failed: ${response.statusCode} ${responseBody}');
    }
  }
}
