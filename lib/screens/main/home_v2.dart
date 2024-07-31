import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:rive/rive.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/models/profile.dart';
import 'package:equilead/models/remote_config.dart';
import 'package:equilead/providers/college.dart';
import 'package:equilead/providers/events.dart';
import 'package:equilead/providers/opportunity.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/screens/checkin.dart';
import 'package:equilead/screens/event/upcoming_events.dart';
import 'package:equilead/screens/opportunity/listing.dart';
import 'package:equilead/screens/vouch.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/utils/notification_service.dart';
import 'package:equilead/utils/remote_config.dart';
import 'package:equilead/utils/shared_prefs.dart';
import 'package:equilead/utils/toast.dart';
import 'package:equilead/widgets/animation/delay_animation.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/animation/size_transition.dart';
import 'package:equilead/widgets/common/membership_card.dart';
import 'package:equilead/widgets/common/opportunity_card.dart';
import 'package:equilead/widgets/common/toast.dart';
import 'package:equilead/widgets/event/card.dart';
import 'package:equilead/widgets/marquee.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeV2 extends ConsumerStatefulWidget {
  const HomeV2({super.key});

  @override
  _HomeV2State createState() => _HomeV2State();
}

class _HomeV2State extends ConsumerState<HomeV2>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  bool isProfileLoading = false;
  late AnimationController? animationController;
  Profile profile = Profile();
  String collegeName = '';
  bool showGradient = true;
  int easterEggTextIndex = 0;
  Size get size => MediaQuery.of(context).size;
  String homeBg = "";

  String marqueeText = '';
  Kolambi kolambi = Kolambi();
  List<QuickAction> quickActions = [];
  List<Widget> _listOfItems = [];
  FirebaseMessaging fcmessaging = FirebaseMessaging.instance;
  late StreamSubscription subscription;

  @override
  void initState() {
    var userId = SharedPrefs().getUserID();
    if (userId.isNotEmpty) {
      fcmessaging.subscribeToTopic(userId);
    }
    NotificationService.inAppMessaging.triggerEvent("home_loaded");
    subscription = RemoteConfig.remoteConfig.onConfigUpdated.listen((onData) {
      getMarquee();
    });
    lottieAnimation();
    getAllData();
    super.initState();
  }

  getAllData() async {
    var res = await Future.wait([
      getMarquee(),
      getOpportunities(),
      getEvents(),
    ]);

    if (res.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    var res = await Future.wait([
      getKolambi(),
      getQuickActions(),
      getProfileData(),
    ]);
    if (ref.watch(opportunityProvider).isEmpty) {
      await getOpportunities();
    }
    if (ref.read(featuredEventProvider).isEmpty) {
      await getEvents();
    }
    if (res.isNotEmpty) {
      await getHomeIndex();
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    animationController!.dispose();
    subscription.cancel();
    super.dispose();
  }

  void lottieAnimation() {
    animationController = AnimationController(vsync: this);
  }

  Future<void> getProfileData() async {
    setState(() {
      isProfileLoading = true;
    });
    var userId = SharedPrefs().getUserID();
    print("-> " + userId);
    var p = await ref.read(profileProvider.notifier).getProfile(userId);
    if (p.id != null) {
      setState(() {
        profile = p;
        isProfileLoading = false;
      });
    }
  }

  Future<void> getCollege() async {
    var resp = await NetworkUtils().httpGet('suborg/${profile.subOrgId}');
    if (resp?.statusCode == 200) {
      var data = jsonDecode(resp!.body);
      if (data != null) {
        ref.read(collegeNameProvider.notifier).update(data['name']);
        setState(() {
          collegeName = data['name'];
        });
      }
    }
  }

  Future<void> getEvents() async {
    var upcomingEventRef = ref.read(upcomingEventProvider.notifier);
    var featuredEventRef = ref.read(featuredEventProvider.notifier);
    await upcomingEventRef.getEvents();
    await featuredEventRef.getEvents();
  }

  Future<void> getOpportunities() async {
    var opportunityRef = ref.read(opportunityProvider.notifier);
    await opportunityRef.getOpportunities();
  }

  void indexRandomize() {
    var index = Random().nextInt(AppConstants.easterEggText.length);
    while (index == easterEggTextIndex) {
      index = Random().nextInt(AppConstants.easterEggText.length);
    }
    setState(() {
      easterEggTextIndex = index;
    });
  }

  Future<void> getQuickActions() async {
    var data = await RemoteConfig().getQuickActionData();
    if (data.isNotEmpty) {
      setState(() {
        quickActions = data;
      });
    } else {
      setState(() {
        quickActions = [];
      });
    }
  }

  Future<void> getKolambi() async {
    setState(() {
      kolambi = Kolambi();
    });
    var data = await RemoteConfig().getKolambi();
    if (data.title != null && data.url != null) {
      setState(() {
        kolambi = data;
      });
    }
  }

  Future<void> getMarquee() async {
    var data = await RemoteConfig().getHomeMarquee();
    if (data.isNotEmpty) {
      setState(() {
        marqueeText =
            'Together, we build the future: 💃Empower, 🤝🏽Volunteer, 📝Lead ✨';
      });
    }
  }

  Future getHomeIndex() async {
    _listOfItems = [
      Sizetransition(child: _featuredOpportunitySection()),
      Sizetransition(child: _featuredEventsSection()),
      Sizetransition(child: _kolambiSection()),
      // Sizetransition(child: _quickActionSection()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : SizedBox(
              width: size.width,
              height: size.height,
              child: SingleChildScrollView(
                primary: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _headerNavigationSection(context, size),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _listOfItems,
                    ),
                    // _easterEggSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _headerNavigationSection(BuildContext context, Size size) {
    return Stack(
      children: [
        Image.network(
          homeBg,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/home_gradient.png',
            );
          },
        ),
        SafeArea(
          bottom: false,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 16),
                DelayedAnimation(
                  delayedAnimation: 300,
                  aniOffsetX: 0,
                  aniOffsetY: -0.18,
                  aniDuration: 250,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PressEffect(
                        onPressed: isProfileLoading
                            ? () {}
                            : () async {
                                await getMembershipCard();
                              },
                        child: Container(
                          padding: EdgeInsets.all(0.1),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            children: [
                              SizedBox(
                                height: 32,
                                width: 32,
                                child: Center(
                                  child: Lottie.asset(
                                    'assets/lottie/membership.json',
                                    repeat: true,
                                    frameRate: FrameRate(120),
                                    controller: animationController,
                                    onLoaded: (composition) {
                                      animationController!
                                        ..duration = composition.duration
                                        ..forward();
                                      animationController!.addListener(() {
                                        if (animationController!.isCompleted) {
                                          animationController!.repeat();
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 32,
                                width: 32,
                                child: Center(
                                  child: SvgPicture.asset(
                                    "assets/icons/home-l.svg",
                                    height: 50,
                                    width: 50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                DelayedAnimation(
                  delayedAnimation: 370,
                  aniOffsetX: 0,
                  aniOffsetY: -0.2,
                  aniDuration: 400,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.6,
                        color: Colors.black,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            HomeNavigationChip(
                              flex: 10,
                              title: 'Activites',
                              iconPath: 'assets/icons/cube.svg',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => UpcomingEvents(),
                                  ),
                                );
                              },
                            ),
                            HomeNavigationChip(
                              flex: 11,
                              title: 'Opportunities',
                              iconPath: 'assets/icons/opportunity_home.svg',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => OpportunityListing(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            HomeNavigationChip(
                              flex: 10,
                              title: 'Vouch',
                              iconPath: 'assets/icons/vouch_home.svg',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => VouchPage(),
                                  ),
                                );
                              },
                            ),
                            HomeNavigationChip(
                              flex: 11,
                              title: 'Check-in',
                              iconPath: 'assets/icons/checkin_home.svg',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SpaceCheckIn(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        marqueeText.isNotEmpty
                            ? Container(
                                width: size.width,
                                height: 38,
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                ),
                                child: Marquee(
                                  text: marqueeText,
                                  style: TextStyle(
                                    fontFamily: 'General Sans',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Colors.white,
                                    height: 1.1,
                                  ),
                                  scrollAxis: Axis.horizontal,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: 20.0,
                                  velocity: 50.0,
                                  startPadding: 10.0,

                                  // accelerationDuration: Duration(seconds: 1),
                                  // accelerationCurve: Curves.linear,
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _featuredOpportunitySection() {
    return ref.watch(opportunityProvider).isEmpty
        ? SizedBox.shrink()
        : Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: DelayedAnimation(
                  delayedAnimation: 450,
                  aniOffsetX: 0,
                  aniOffsetY: -0.18,
                  aniDuration: 250,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Opportunities',
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Spacer(),
                          ref.watch(opportunityProvider).length > 3
                              ? PressEffect(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OpportunityListing(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        width: 0.6,
                                        color: Colors.black,
                                      ),
                                    ),
                                    child: Text(
                                      'View all'.toUpperCase(),
                                      style: TextStyle(
                                        fontFamily: 'General Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                      SizedBox(height: 8),
                      ListView.separated(
                        itemCount: ref.watch(opportunityProvider).length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          return DelayedAnimation(
                            delayedAnimation: 500 + (index * 50),
                            aniOffsetX: 0,
                            aniOffsetY: -0.18,
                            aniDuration: 250,
                            child: OpportunityCard(
                              opportunity:
                                  ref.watch(opportunityProvider)[index],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return DelayedAnimation(
                            delayedAnimation: 680 + (index * 50),
                            aniOffsetX: 0,
                            aniOffsetY: -0.18,
                            aniDuration: 250,
                            child: const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xffEBEBEB),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              _curlySeparator()
            ],
          );
  }

  Widget _featuredEventsSection() {
    return ref.read(featuredEventProvider).isNotEmpty
        ? Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DelayedAnimation(
                        delayedAnimation: 600,
                        aniOffsetX: 0,
                        aniOffsetY: -0.18,
                        aniDuration: 250,
                        child: Row(
                          children: [
                            Text(
                              'Featured events',
                              style: TextStyle(
                                fontFamily: 'General Sans',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Spacer(),
                            // PressEffect(
                            //   onPressed: () {
                            //     Navigator.of(context).push(
                            //       MaterialPageRoute(
                            //         builder: (context) => UpcomingEvents(),
                            //       ),
                            //     );
                            //   },
                            //   child: Container(
                            //     padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(30),
                            //       border: Border.all(
                            //         width: 0.6,
                            //         color: Colors.black,
                            //       ),
                            //     ),
                            //     child: Text(
                            //       'View all'.toUpperCase(),
                            //       style: TextStyle(
                            //         fontFamily: 'General Sans',
                            //         fontSize: 12,
                            //         fontWeight: FontWeight.w500,
                            //         color: Colors.black,
                            //         height: 1.2,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    DelayedAnimation(
                      delayedAnimation: 600,
                      aniOffsetX: -0.2,
                      aniOffsetY: 0,
                      aniDuration: 300,
                      child: SizedBox(
                        height: 350,
                        width: size.width,
                        child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: ref.read(featuredEventProvider).length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            var events = ref.read(featuredEventProvider);
                            return EventCard(
                              fullWidth:
                                  ref.read(featuredEventProvider).length == 1,
                              featured: events[index].featured!,
                              index: index,
                              eventUniqueId: events[index].uniqueId!,
                              title: events[index].name!,
                              coloured: true,
                              horizontalPadding: true,
                              image: events[index].banner,
                              isExternal: events[index].isExternal!,
                              date: events[index].startDate.day ==
                                      events[index].endDate.day
                                  ? DateFormat('d MMM · hh:mm a')
                                          .format(events[index].startDate) +
                                      ' - ' +
                                      DateFormat('hh:mm a')
                                          .format(events[index].endDate)
                                  : DateFormat('d MMM · hh:mm a')
                                          .format(events[index].startDate) +
                                      ' - ' +
                                      DateFormat('d MMM · hh:mm a')
                                          .format(events[index].endDate),
                              location: events[index].location ?? "",
                              type: events[index].type!,
                              isInviteOnly: events[index].isInviteOnly!,
                              isVirtual: events[index].isVirtual!,
                            );
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              _curlySeparator()
            ],
          )
        : SizedBox.shrink();
  }

  Widget _kolambiSection() {
    Size size = MediaQuery.of(context).size;
    return kolambi.title != null
        ? DelayedAnimation(
            delayedAnimation: 650,
            aniOffsetX: 0,
            aniOffsetY: -0.1,
            aniDuration: 300,
            child: Container(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Column(
                children: [
                  Container(
                    width: size.width,
                    margin: EdgeInsets.only(top: 16, bottom: 20),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.deepPurpleAccent[100],
                            image: DecorationImage(
                              image:
                                  AssetImage('assets/images/yellow_grid.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            width: size.width,
                            color: Colors.transparent,
                            padding: EdgeInsets.fromLTRB(20, 32, 20, 32),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 0.6,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'WEEKLY READ',
                                    style: TextStyle(
                                      fontFamily: 'General Sans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    kolambi.title!,
                                    style: TextStyle(
                                      fontFamily: 'General Sans',
                                      fontSize: 32,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      height: 1.12,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  PressEffect(
                                    onPressed: () {
                                      launchUrl(
                                        Uri.parse(kolambi.url!),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 8, 12, 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            kolambi.video! ? 'WATCH' : 'READ',
                                            style: TextStyle(
                                              fontFamily: 'General Sans',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                              height: 1.2,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          SvgPicture.asset(
                                            "assets/icons/arrow-top-right.svg",
                                            height: 16,
                                            width: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Container(
                        //   width: 72,
                        //   height: 72,
                        //   child: RiveAnimation.asset(
                        //     'assets/rive/kolambi.riv',
                        //     fit: BoxFit.cover,
                        //   ),
                        //   transform: Matrix4.translationValues(-20, -20.0, 0.0),
                        // ),
                      ],
                    ),
                  ),
                  _curlySeparator()
                ],
              ),
            ),
          )
        : SizedBox.shrink();
  }

  Widget _curlySeparator() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 32, 0, 32),
      child: Image.asset("assets/images/separator.png"),
    );
  }

  Widget _quickActionSection() {
    return quickActions.isNotEmpty
        ? Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: ListView.separated(
                  itemCount: quickActions.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return DelayedAnimation(
                      delayedAnimation: 750,
                      aniOffsetX: 0,
                      aniOffsetY: -0.1,
                      aniDuration: 300,
                      child: QuickActionCard(
                        iconPath: quickActions[index].iconPath!,
                        title: quickActions[index].title!,
                        description: quickActions[index].description!,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          launchUrl(
                            Uri.parse(quickActions[index].action!),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 24);
                  },
                ),
              ),
              _curlySeparator()
            ],
          )
        : SizedBox.shrink();
  }

  Widget _easterEggSection() {
    return DelayedAnimation(
      delayedAnimation: 850,
      aniOffsetX: 0,
      aniOffsetY: -0.1,
      aniDuration: 300,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Center(
          child: Column(
            children: [
              PressEffect(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  indexRandomize();
                },
                child: Text(
                  AppConstants.easterEggText[easterEggTextIndex],
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 60,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.1),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 48),
              Row(
                children: [
                  Spacer(),
                  Container(
                    height: 5,
                    width: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    height: 5,
                    width: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    height: 5,
                    width: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    height: 5,
                    width: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),
                  Spacer(),
                ],
              ),
              SizedBox(height: 32),
              SizedBox(
                height: 15,
                child: Opacity(
                  opacity: 0.12,
                  child: Image.asset("assets/images/LogoBLACK.png"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getMembershipCard() async {
    await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return PressEffect(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Container(
              height: size.height,
              width: size.width,
              child: MembershipCard(
                profile: profile,
                college: collegeName,
              ),
            ),
          );
        });
  }
}

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.iconPath,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String iconPath;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PressEffect(
      onPressed: () {
        onTap();
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            width: 0.6,
            color: Colors.black,
          ),
        ),
        child: Row(
          children: [
            Image.network(
              iconPath,
              height: 32,
              width: 32,
            ),
            SizedBox(width: 16),
            SizedBox(
              width: size.width * 0.67,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeNavigationChip extends StatelessWidget {
  const HomeNavigationChip({
    super.key,
    this.title,
    this.iconPath,
    required this.onTap,
    required this.flex,
  });

  final String? title;
  final String? iconPath;
  final VoidCallback onTap;
  final int flex;

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return Expanded(
      flex: flex,
      child: PressEffect(
        onPressed: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              width: 0.6,
              color: Colors.black,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title!,
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Spacer(),
              SvgPicture.asset(iconPath!)
            ],
          ),
        ),
      ),
    );
  }
}
