import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:equilead/models/profile.dart';
import 'package:equilead/providers/college.dart';
import 'package:equilead/providers/events.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/utils/shared_prefs.dart';
import 'package:equilead/widgets/animation/animated_gradient_container.dart';
import 'package:equilead/widgets/animation/delay_animation.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/membership_card.dart';
import 'package:equilead/widgets/event/card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  bool isProfileLoading = false;
  late AnimationController? animationController;
  Profile profile = Profile();
  String collegeName = '';
  bool showGradient = true;

  @override
  void initState() {
    var userId = SharedPrefs().getUserID();

    lottieAnimation();
    getEvents();
    getProfileData();
    gradientStopper();
    super.initState();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  lottieAnimation() {
    animationController = AnimationController(vsync: this);
  }

  gradientStopper() {
    Future.delayed(Duration(milliseconds: 3500), () {
      setState(() {
        showGradient = false;
      });
    });
  }

  getProfileData() async {
    setState(() {
      isProfileLoading = true;
    });
    var userId = SharedPrefs().getUserID();
    var p = await ref.read(profileProvider.notifier).getProfile(userId);
    if (p.id != null) {
      setState(() {
        profile = p;
        isProfileLoading = false;
      });
      if (p.isStudent!) {
        getCollege();
      }
    }
  }

  void getCollege() async {
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

  getEvents() async {
    var upcomingEventRef = ref.read(upcomingEventProvider.notifier);
    var featuredEventRef = ref.read(featuredEventProvider.notifier);
    await upcomingEventRef.getEvents();
    await featuredEventRef.getEvents();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Image.asset('assets/images/home_gradient.png'),
          Container(
            width: size.width,
            color: Colors.transparent,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: DelayedAnimation(
                        delayedAnimation: 380,
                        aniOffsetX: 0,
                        aniOffsetY: -0.18,
                        aniDuration: 250,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            PressEffect(
                              onPressed: isProfileLoading
                                  ? () {}
                                  : () async {
                                      await getMembershipCard();
                                    },
                              child: Stack(
                                children: [
                                  SizedBox(
                                    height: 50,
                                    width: 50,
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
                                            if (animationController!
                                                .isCompleted) {
                                              animationController!.repeat();
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                    width: 50,
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
                            Spacer(),
                            PressEffect(
                              onPressed: () {
                                context.go('/vouch');
                                // Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //     builder: (context) => VouchedBy(),
                                //   ),
                                // );
                              },
                              child: AnimatedGradientBorder(
                                isActivated: showGradient,
                                borderSize: 1,
                                glowSize: 1,
                                gradientColors: [
                                  Color(0xffFD9F2B),
                                  Colors.green,
                                  Colors.green,
                                  Color(0xffFED84D),
                                ],
                                borderRadius: BorderRadius.circular(30),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 900),
                                  curve: Curves.easeIn,
                                  padding: EdgeInsets.all(8),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: showGradient
                                          ? Colors.white
                                          : Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/heart.svg",
                                        height: 13.2,
                                        width: 13.2,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'VOUCH',
                                        style: TextStyle(
                                          fontFamily: 'General Sans',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          height: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              width: showGradient ? 8 : 14,
                            ),
                            PressEffect(
                              onPressed: () {
                                context.go('/tickets');
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/tickets.svg",
                                  height: 13.2,
                                  width: 13.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ref.read(featuredEventProvider).isNotEmpty
                        ? SizedBox(height: 24)
                        : SizedBox.shrink(),
                    ref.read(featuredEventProvider).isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: DelayedAnimation(
                              delayedAnimation: 400,
                              aniOffsetX: -0.2,
                              aniOffsetY: 0,
                              aniDuration: 250,
                              child: SizedBox(
                                height: 317,
                                width: size.width,
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      ref.read(featuredEventProvider).length,
                                  itemBuilder: (context, index) {
                                    var events =
                                        ref.read(featuredEventProvider);
                                    return EventCard(
                                      fullWidth: ref
                                              .read(featuredEventProvider)
                                              .length ==
                                          1,
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
                                                  .format(
                                                      events[index].startDate) +
                                              ' - ' +
                                              DateFormat('hh:mm a')
                                                  .format(events[index].endDate)
                                          : DateFormat('d MMM · hh:mm a')
                                                  .format(
                                                      events[index].startDate) +
                                              ' - ' +
                                              DateFormat('d MMM · hh:mm a')
                                                  .format(
                                                      events[index].endDate),
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
                            ),
                          )
                        : SizedBox.shrink(),
                    SizedBox(height: 40),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: DelayedAnimation(
                        delayedAnimation: 600,
                        aniOffsetX: 0,
                        aniOffsetY: -0.18,
                        aniDuration: 250,
                        child: Text(
                          "Upcoming Events",
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: size.width,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: ref.watch(upcomingEventProvider).isEmpty
                          ? DelayedAnimation(
                              delayedAnimation: 650,
                              aniOffsetX: 0,
                              aniOffsetY: -0.18,
                              aniDuration: 250,
                              child: Center(
                                  child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 64, 16, 32),
                                child: Text(
                                  'No upcoming events',
                                  style: TextStyle(
                                    fontFamily: 'General Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black45,
                                    height: 0.9,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              )),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: ref.read(upcomingEventProvider).length,
                              itemBuilder: (context, index) {
                                var events = ref.read(upcomingEventProvider);
                                return DelayedAnimation(
                                  delayedAnimation: 700 + (index * 80),
                                  aniOffsetX: 0,
                                  aniOffsetY: -0.18,
                                  aniDuration: 250,
                                  child: EventCard(
                                    index: index,
                                    featured: events[index].featured!,
                                    eventUniqueId: events[index].uniqueId!,
                                    title: events[index].name!,
                                    coloured: false,
                                    isExternal: events[index].isExternal!,
                                    date: events[index].startDate.day ==
                                            events[index].endDate.day
                                        ? DateFormat('d MMM · hh:mm a').format(
                                                events[index].startDate) +
                                            ' - ' +
                                            DateFormat('hh:mm a')
                                                .format(events[index].endDate)
                                        : DateFormat('d MMM · hh:mm a').format(
                                                events[index].startDate) +
                                            ' - ' +
                                            DateFormat('d MMM · hh:mm a')
                                                .format(events[index].endDate),
                                    location: events[index].location ?? "",
                                    type: events[index].type!,
                                    isInviteOnly: events[index].isInviteOnly!,
                                    isVirtual: events[index].isVirtual!,
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return DelayedAnimation(
                                  delayedAnimation: 775 + (index * 80),
                                  aniOffsetX: 0,
                                  aniOffsetY: -0.18,
                                  aniDuration: 250,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 4),
                                      Divider(
                                        thickness: 1,
                                        color: Color(0xffEBEBEB),
                                      ),
                                      SizedBox(height: 4),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getMembershipCard() async {
    Size size = MediaQuery.of(context).size;
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
