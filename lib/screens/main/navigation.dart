import 'dart:async';
import 'dart:io';

import 'package:equilead/providers/checkinList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:equilead/screens/main/home_v2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equilead/providers/events.dart';
import 'package:equilead/utils/remote_config.dart';
import 'package:equilead/utils/shared_prefs.dart';
import 'package:equilead/widgets/dialog_builder/builder.dart';
import 'package:equilead/widgets/version.dart';
import 'profile.dart';
import 'space.dart';
import 'package:equilead/widgets/common/bottom_nav.dart';
import 'package:equilead/constants.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int selectedIndex = 0;
  bool isStudent = false;
  List<Widget> originalList = [
    HomeV2(),
    SpacePage(),
    MemberProfile(),
  ];
  Map<int, bool> originalDic = {
    0: true,
    1: false,
    2: false,
  };
  List<int> listScreensIndex = [0];
  late List<Widget> listScreens = [originalList[0]];

  /// change navigation tabs
  void onItemSelected(int index) {
    HapticFeedback.lightImpact();
    if (originalDic[index] == false) {
      listScreensIndex.add(index);
      originalDic[index] = true;
      listScreensIndex.sort();
      listScreens = listScreensIndex.map((index) {
        return originalList[index];
      }).toList();
    }
    setState(() {
      selectedIndex = index;
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

  /// function to check if the user is a student or not
  void checkStudentStatus() async {
    bool student = SharedPrefs().getStudentStatus();
    setState(() {
      isStudent = student;
    });
  }

  Future getCurrentVersion() async {
    var getData = await RemoteConfig().getCurrentVersion();
    var platform = Platform.isAndroid ? "android" : "ios";
    if (getData.isNotEmpty) {
      var lateVersion = getData[platform]["version"];
      Version currentVersion = Version.parse(AppConstants.version);
      Version latestVersion = Version.parse(lateVersion);
      if (latestVersion > currentVersion) {
        bool forceUpdate = getData[platform]["forceupdate"];
        DialogBuilder(context: context).HideDialog();
        DialogBuilder(context: context).ShowUpgrade(forceUpdate);
      }
    }
  }

  @override
  void initState() {
    // getCurrentVersion();
    // subscription =
    //     RemoteConfig.remoteConfig.onConfigUpdated.listen((event) async {
    //   getCurrentVersion();
    // });
    checkStudentStatus();
    getHomeEvents();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: listScreensIndex.indexOf(selectedIndex),
              children: listScreens,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 100,
                width: size.width,
                padding: EdgeInsets.symmetric(
                    horizontal:
                        isStudent ? size.width * 0.05 : size.width * 0.1),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.5, 1],
                    colors: [
                      Color.fromARGB(0, 254, 254, 254),
                      Colors.white.withOpacity(0.7),
                      Colors.white,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    BottomNavItem(
                      iconPath: "assets/icons/home.svg",
                      title: "Home",
                      isSelected: selectedIndex == 0,
                      onTap: () {
                        onItemSelected(0);
                      },
                    ),
                    Spacer(),
                    BottomNavItem(
                      iconPath: "assets/icons/space.svg",
                      title: "Space",
                      isSelected: selectedIndex == 1,
                      onTap: () async {
                        onItemSelected(1);
                        await ref
                            .read(checkInListProvider.notifier)
                            .getCheckInListData();
                      },
                    ),
                    Spacer(),
                    BottomNavItem(
                      iconPath: "assets/icons/profile.svg",
                      title: "Profile",
                      isSelected: selectedIndex == 2,
                      onTap: () {
                        onItemSelected(2);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
