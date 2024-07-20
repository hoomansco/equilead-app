import 'dart:io';

import 'package:equilead/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equilead/routes.dart';
import 'package:equilead/utils/notification_service.dart';
import 'package:equilead/utils/remote_config.dart';
import 'package:equilead/utils/shared_prefs.dart';
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Platform.isAndroid) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  } else {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.ios);
  }
  if (message.notification?.title != null) {
    await NotificationService().initNotification();
    var scheduleDateCloud = DateTime.parse(message.data["schedule_time"]);
    var eventName = message.data["event_name"];
    var now = DateTime.now();
    int differenceInMinutes = scheduleDateCloud.difference(now).inMinutes;
    var evnetdate = now.add(Duration(minutes: differenceInMinutes - 11));
    tz.Location location = tz.local;
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(evnetdate, location);
    if (scheduledDate.isAfter(now)) {
      NotificationService().scheduleNotification(
          scheduledNotificationDateTime: scheduledDate,
          id: message.hashCode,
          title: "${eventName} starts in 10 minutes",
          body: message.notification!.body);
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs().init();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (Platform.isAndroid) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  } else {
    await Firebase.initializeApp();
  }
  await RemoteConfig().init();
  await RemoteConfig().setDefaults();
  fireForegroundService();
  initFirebaseCloudMessaging();
  NotificationService().initNotification();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => runApp(
      ProviderScope(child: MyApp()),
    ),
  );
}

Future initFirebaseCloudMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');
}

fireForegroundService() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (message.notification != null) {
      await NotificationService().initNotification();
      var scheduleDateCloud = DateTime.parse(message.data["schedule_time"]);
      var eventName = message.data["event_name"];
      var now = DateTime.now();
      int differenceInMinutes = scheduleDateCloud.difference(now).inMinutes;
      var evnetdate = now.add(Duration(minutes: differenceInMinutes - 11));
      tz.Location location = tz.local;
      tz.TZDateTime scheduledDate = tz.TZDateTime.from(evnetdate, location);
      if (scheduledDate.isAfter(now)) {
        NotificationService().scheduleNotification(
            scheduledNotificationDateTime: scheduledDate,
            id: message.hashCode,
            title: "${eventName} starts in 10 minutes",
            body: message.notification!.body);
      }
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print(message.data);
  });
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: AnnotatedRegion(
        value: Platform.isIOS
            ? SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.black,
                systemNavigationBarColor: Colors.transparent,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.black,
              ),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Equilead App',
          theme: ThemeData(
            colorScheme: ColorScheme.light(primary: Colors.black),
            fontFamily: 'General Sans',
            useMaterial3: true,
          ),
          routerConfig: router,
        ),
      ),
    );
  }
}
