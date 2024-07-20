import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:equilead/providers/events.dart';
import 'package:equilead/providers/opportunity.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/utils/shared_prefs.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController? animationController;

  lottieAnimation() {
    animationController = AnimationController(vsync: this);
  }

  @override
  void initState() {
    super.initState();

    lottieAnimation();
    checkLogin();
  }

  Future<bool?>? checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('equilead.hoomans.dev');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return null;
  }

  void checkLogin() async {
    var isConnected = await checkInternetConnection();
    var id = SharedPrefs().getUserID();
    var profile = await ref.read(profileProvider.notifier).getProfile(id);
    if (profile.id != null) {
      await getHomeEvents();
      await getOpportunities();
    }

    await Future.delayed(Duration(milliseconds: 2000), () {
      if (isConnected!) {
        if (profile.id != null) {
          context.go('/');
        } else {
          context.go('/auth');
        }
      } else {
        context.go('/no_internet');
      }
    });
  }

  getHomeEvents() async {
    var upcomingEventRef = ref.read(upcomingEventProvider.notifier);
    var featuredEventRef = ref.read(featuredEventProvider.notifier);
    var spaceEventRef = ref.read(spaceEventProvider.notifier);
    await upcomingEventRef.getEvents();
    await featuredEventRef.getEvents();
    await spaceEventRef.getEvents();
  }

  Future<void> getOpportunities() async {
    var opportunityRef = ref.read(opportunityProvider.notifier);
    await opportunityRef.getOpportunities();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  size.width * 0.1, 0, size.width * 0.11, 16),
              // child: Image.asset('assets/images/LogoBLACK.png'),
              child: Lottie.asset(
                'assets/lottie/splash.json',
                repeat: true,
                frameRate: FrameRate(120),
                controller: animationController,
                onLoaded: (composition) {
                  animationController!
                    ..duration = composition.duration
                    ..forward();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
