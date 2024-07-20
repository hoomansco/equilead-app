import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:equilead/models/remote_config.dart';

class RemoteConfig {
  static late FirebaseRemoteConfig remoteConfig;
  factory RemoteConfig() => RemoteConfig._internal();
  RemoteConfig._internal();

  Future init() async {
    remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(seconds: 5),
      ),
    );
    RemoteConfigValue(null, ValueSource.valueStatic);
  }

  Future fetchAndActivate() async {
    try {
      final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
      // Using zero duration to force fetching from remote server.
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );
      await remoteConfig.fetchAndActivate();
    } on PlatformException catch (exception) {
      // Fetch exception.
      print(exception.details);
    } catch (exception) {
      print(exception);
    }
  }

  Future<Map> getCurrentVersion() async {
    await fetchAndActivate();
    var value = remoteConfig.getValue("current_version").asString();
    if (value != "") {
      return Map.from(jsonDecode(value));
    }
    return Map();
  }

  Future<List<QuickAction>> getQuickActionData() async {
    var value = remoteConfig.getValue("quick_action").asString();
    if (value != "") {
      Iterable l = jsonDecode(value);
      List<QuickAction> quickActions =
          List<QuickAction>.from(l.map((model) => QuickAction.fromJson(model)));
      return quickActions;
    }
    return [];
  }

  Future<Map<String, int>> getHomeIndex() async {
    var value = remoteConfig.getValue("home_order_index").asString();
    if (value != "") {
      var data = Map<String, int>.from(jsonDecode(value));
      // Convert the map entries to a list
      List<MapEntry<String, int>> entries = data.entries.toList();

      // Sort the list by the values
      entries.sort((a, b) => a.value.compareTo(b.value));

      // Create a new map from the sorted list
      Map<String, int> sortedMap = Map.fromEntries(entries);
      return sortedMap;
    }
    return Map();
  }

  List getCheckinContacts() {
    var value = remoteConfig.getValue("checkin_contacts").asString();
    if (value != "") {
      var data = List.from(jsonDecode(value));
      return data;
    }
    return [];
  }

  Map getWifiInfo() {
    var value = remoteConfig.getValue("wifi_info").asString();
    if (value != "") {
      var data = jsonDecode(value);
      return Map.castFrom(data);
    }
    return Map();
  }

  Future<Kolambi> getKolambi() async {
    var value = remoteConfig.getValue("kolambi").asString();
    if (value != "") {
      var data = jsonDecode(value);
      return Kolambi.fromJson(data);
    }
    return Kolambi();
  }

  Future<String> getHomeMarquee() async {
    var value = remoteConfig.getValue("marquee").asString();
    if (value != "") {
      return value;
    }
    return "";
  }

  Future<SpaceMarquee> getSpaceMarquee() async {
    var value = remoteConfig.getValue("space_marquee").asString();
    if (value != "") {
      var data = jsonDecode(value);
      return SpaceMarquee.fromJson(data);
    }
    return SpaceMarquee();
  }

  Future<List<SpaceImportantLink>> getSpaceImportantLinks() async {
    var value = remoteConfig.getValue("space_important_links").asString();
    if (value != "") {
      Iterable l = jsonDecode(value);
      List<SpaceImportantLink> importantLinks = List<SpaceImportantLink>.from(
          l.map((model) => SpaceImportantLink.fromJson(model)));
      return importantLinks;
    }
    return [];
  }

  Future setDefaults() async {
    await remoteConfig.setDefaults({
      "kolambi": jsonEncode({
        "url": "https://fs.blog/first-principles/",
        "title": "First Principles: The Building Blocks of True Knowledge",
        "video": false,
        "colorHex": "F7F996"
      }),
      "quick_action": jsonEncode([
        {
          "id": 1,
          "iconPath":
              "https://appbucket-hoomans.s3.ap-south-1.amazonaws.com/disc.png",
          "title": "Yearly Report '22-23",
          "description": "Everything you need to know about us",
          "action":
              "https://drive.google.com/file/d/1RuHc3FCQI0Pbw0u9jid5816G4wHvxH98/view",
          "eventAttribute": "yearly-report-22-23"
        },
        {
          "id": 2,
          "iconPath":
              "https://appbucket-hoomans.s3.ap-south-1.amazonaws.com/file-card.png",
          "title": "Learning Paths",
          "description": "A library with different paths & roadmaps",
          "action": "https://paths.tinkerhub.org/",
          "eventAttribute": "learning-path"
        },
        {
          "id": 3,
          "iconPath":
              "https://appbucket-hoomans.s3.ap-south-1.amazonaws.com/diamond.png",
          "title": "Don't just dream of a better future",
          "description": "Help create it. Donate now.",
          "action": "https://www.tinkerhub.org/donate",
          "eventAttribute": "donation"
        }
      ]),
      "marquee": "TinkerSpace is open now. Keep tinkering. ✨",
    });
  }
}
