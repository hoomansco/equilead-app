import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/models/remote_config.dart';
import 'package:equilead/providers/checkin.dart';
import 'package:equilead/providers/events.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/screens/checkin.dart';
import 'package:equilead/screens/checkin_successfully.dart';
import 'package:equilead/screens/event/upcoming_events.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/utils/notification_service.dart';
import 'package:equilead/utils/remote_config.dart';
import 'package:equilead/widgets/animation/delay_animation.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/action_sheet.dart';
import 'package:equilead/widgets/common/checkin_chip.dart';
import 'package:equilead/widgets/common/crowd.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';
import 'package:equilead/widgets/common/space_nav.dart';
import 'package:equilead/widgets/common/swipe_confirm.dart';
import 'package:equilead/widgets/event/card.dart';
import 'package:equilead/widgets/marquee.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timezone/timezone.dart' as tz;

enum CrowdStatus { crowded, sparsely, free }

class SpacePage extends ConsumerStatefulWidget {
  const SpacePage({super.key});

  @override
  _SpacePageState createState() => _SpacePageState();
}

class _SpacePageState extends ConsumerState<SpacePage> {
  // bool isCheckedIn = false;
  bool isLoading = false;
  bool isCheckinLoading = false;
  CrowdStatus crowdedStatus = CrowdStatus.free;
  // List<PartnerContact> spaceContacts = [];
  List<SpaceImportantLink> impLinks = [];
  bool _isNight = false;

  SpaceMarquee spaceMarquee = SpaceMarquee();
  MarqueeLevel marqueeLevel = MarqueeLevel.info;

  @override
  void initState() {
    checkIfCheckedIn();
    checkCrowded();
    getEvents();
    // getSpaceContacts();
    checkNight();
    getMarquee();
    getImpLinks();

    super.initState();
  }

  Future<void> checkCrowded() async {
    var resp = await NetworkUtils().httpGet("checkin/active");
    print(resp!.body);
    if (resp!.statusCode == 200) {
      var data = (json.decode(resp.body) ?? []) as List;
      if (data.length > 44) {
        setState(() {
          crowdedStatus = CrowdStatus.crowded;
        });
      } else if (data.length > 35) {
        setState(() {
          crowdedStatus = CrowdStatus.sparsely;
        });
      } else {
        setState(() {
          crowdedStatus = CrowdStatus.free;
        });
      }
    }
  }

  Future<void> getImpLinks() async {
    var data = await RemoteConfig().getSpaceImportantLinks();
    if (data.isNotEmpty) {
      setState(() {
        impLinks = data;
      });
    } else {
      setState(() {
        impLinks = [];
      });
    }
  }

  Future<void> checkNight() async {
    var currentTime = DateTime.now();
    var evening = DateTime(
        currentTime.year, currentTime.month, currentTime.day, 18, 30, 0, 0, 0);
    var morning = DateTime(
        currentTime.year, currentTime.month, currentTime.day, 5, 30, 0, 0, 0);

    Future.delayed(Duration(milliseconds: 600), () {
      setState(() {
        _isNight =
            currentTime.isAfter(evening) || currentTime.isBefore(morning);
      });
    });
  }

  Future<void> getEvents() async {
    var spaceEventRef = ref.read(spaceEventProvider.notifier);
    await spaceEventRef.getEvents();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> checkIfCheckedIn() async {
    var profile = ref.read(profileProvider);
    ref.read(checkInProvider.notifier).getCheckInData(profile.id!);
  }

  Future<void> spaceCheckout() async {
    var checkInRef = ref.watch(checkInProvider.notifier);
    setState(() {
      isCheckinLoading = true;
    });
    var checkIn = ref.read(checkInProvider);
    await checkInRef.checkOut(checkIn.id!);
    NotificationService().cancelNotification(0);
    setState(() {
      isCheckinLoading = false;
    });
    await checkIfCheckedIn();
  }

  Future<void> spaceCheckoutExtend(int hours) async {
    var checkInRef = ref.watch(checkInProvider.notifier);
    var checkIn = ref.read(checkInProvider);
    await checkInRef.checkOutExtend(checkIn.id!, checkIn.checkOutTime!, hours);
    await NotificationService().cancelNotification(0);
    var scheduleTime = checkIn.checkOutTime!.add(
      Duration(minutes: (hours * 60) - 15),
    );
    tz.Location location = tz.local;
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(scheduleTime, location);
    NotificationService().scheduleNotification(
        scheduledNotificationDateTime: scheduledDate,
        title: "Time's up! Check-out time is approaching",
        body:
            "To ensure that everyone gets the opportunity to use this space, we recommend not using it for more than 4 hours in a single day.");
    checkIfCheckedIn();
  }

  // Future<void> getSpaceContacts() async {
  //   var resp = await NetworkUtils().httpGet("partner/space/contacts");
  //   if (resp!.statusCode == 200) {
  //     Iterable l = json.decode(resp.body);
  //     List<PartnerContact> contacts = List<PartnerContact>.from(
  //         l.map((model) => PartnerContact.fromJson(model))).toList();
  //     setState(() {
  //       spaceContacts = contacts;
  //     });
  //   }
  // }

  Future<void> getMarquee() async {
    setState(() {
      spaceMarquee = SpaceMarquee();
    });
    var data = await RemoteConfig().getSpaceMarquee();
    if (data.text.isNotEmpty && data.level != null) {
      setState(() {
        spaceMarquee = data;
      });
    }
  }

  Future<void> _checkoutConfirmModal(BuildContext context) async {
    return await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isDismissible: !isCheckinLoading,
      context: context,
      elevation: 0,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext newContext, StateSetter setSheetState) =>
            Container(
          height: 250,
          padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
          color: Colors.transparent,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Confirm Checkout?',
                      style: TextStyle(
                        fontFamily: 'General Sans',
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'You are checking out of Equilead. Until next time 👋',
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff2E2E2E),
                              letterSpacing: -0.2,
                              height: 1.32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    SwipeIconRegister(
                      title: 'SWIPE TO CONFIRM',
                      onSwipe: () async {
                        setSheetState(() {
                          isCheckinLoading = true;
                        });
                        var checkIn = ref.read(checkInProvider);
                        await spaceCheckout();
                        setSheetState(() {
                          isCheckinLoading = false;
                        });

                        if (checkIn.id != null) {
                          Future.delayed(Duration(milliseconds: 1500), () {
                            Navigator.pop(context);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              isCheckinLoading
                  ? Container(
                      height: 400,
                      width: 600,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
              Center(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: ref.watch(checkInProvider).id == null ? 400 : 0,
                  width: ref.watch(checkInProvider).id == null ? 600 : 0,
                  decoration: BoxDecoration(
                    color: Color(0xff3cd377),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ref.watch(checkInProvider).id == null
                      ? Icon(
                          Icons.check,
                          size: 70,
                          color: Colors.white,
                        )
                      : SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AnnotatedRegion(
      value: Platform.isIOS
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.white,
              systemNavigationBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.white,
            ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: size.width,
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/images/space.png",
                          scale: 1,
                        ),
                        SizedBox(
                          height: ref.read(checkInProvider).id != null
                              ? spaceMarquee.text.isNotEmpty
                                  ? 278
                                  : 240
                              : spaceMarquee.text.isNotEmpty
                                  ? 158
                                  : 120,
                        ),
                      ],
                    ),
                    ref.watch(checkInProvider).id != null
                        ? Positioned(
                            top: size.width * 0.78,
                            left: 0,
                            child: CheckInWidget(
                              size: size,
                              endTime: ref
                                  .watch(checkInProvider)
                                  .checkOutTime!
                                  .toLocal(),
                              triggerCheckIn: checkIfCheckedIn,
                              checkout: () async {
                                await _checkoutConfirmModal(context);
                              },
                              extend: (val) => spaceCheckoutExtend(val),
                              crowdedStatus: crowdedStatus,
                              marquee: spaceMarquee,
                            ),
                          )
                        : Positioned(
                            top: size.width * 0.78,
                            left: 0,
                            child: DelayedAnimation(
                              delayedAnimation: 300,
                              aniOffsetX: 0,
                              aniOffsetY: -0.1,
                              aniDuration: 200,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: size.width * 0.9,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.05),
                                    padding:
                                        EdgeInsets.fromLTRB(16, 20, 16, 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                        top: BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                        bottom: BorderSide(
                                          color: Colors.black,
                                          width: 0.5,
                                        ),
                                        left: BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                        right: BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Join the virtual space",
                                              style: TextStyle(
                                                fontFamily: 'General Sans',
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            // CrowdedSpace(
                                            //   status: crowdedStatus,
                                            // )
                                          ],
                                        ),
                                        PressEffect(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SpaceCheckIn(),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.fromLTRB(
                                                12, 8, 12, 8),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Text(
                                              'Check-in'.toUpperCase(),
                                              style: TextStyle(
                                                fontFamily: 'General Sans',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: size.width * 0.9,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.05,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black,
                                          width: 0.5,
                                        ),
                                        left: BorderSide(
                                          color: Colors.black,
                                          width: 0.5,
                                        ),
                                        right: BorderSide(
                                          color: Colors.black,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SpaceNav(
                                          flex: 10,
                                          title: 'Activities',
                                          iconPath:
                                              'assets/icons/events_space.svg',
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UpcomingEvents(
                                                  isSpaceEvent: true,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        SpaceNav(
                                          flex: 11,
                                          title: 'Coming soon..',
                                          iconPath:
                                              'assets/icons/help_space.svg',
                                          onTap: () {},
                                        ),
                                      ],
                                    ),
                                  ),
                                  spaceMarquee.text.isNotEmpty
                                      ? Container(
                                          width: size.width * 0.9,
                                          height: 38,
                                          padding:
                                              EdgeInsets.fromLTRB(0, 10, 0, 0),
                                          decoration: BoxDecoration(
                                              color: spaceMarquee.level ==
                                                      MarqueeLevel.info
                                                  ? Colors.black
                                                  : spaceMarquee.level ==
                                                          MarqueeLevel.alert
                                                      ? Color(0xffFF0059)
                                                      : Color(0xff5F5CE5),
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.black,
                                                  width: 1,
                                                ),
                                                left: BorderSide(
                                                  color: Colors.black,
                                                  width: 1,
                                                ),
                                                right: BorderSide(
                                                  color: Colors.black,
                                                  width: 1,
                                                ),
                                              )),
                                          child: Marquee(
                                            text:
                                                "Together, we build the future: 💃Empower, 🤝🏽Volunteer, 📝Lead ✨",
                                            style: TextStyle(
                                              fontFamily: 'General Sans',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: Colors.white,
                                              height: 1.1,
                                            ),
                                            scrollAxis: Axis.horizontal,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            blankSpace: 20.0,
                                            velocity: 50.0,
                                            startPadding: 10.0,
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
              ref.read(checkInProvider).id != null
                  ? SizedBox(height: 24)
                  : SizedBox.shrink(),
              SizedBox.shrink(),
              SizedBox(height: 32),
              // SingleChildScrollView(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       impLinks.isEmpty
              //           ? SizedBox.shrink()
              //           : SizedBox(
              //               width: size.width,
              //               child: ListView.separated(
              //                 itemCount: impLinks.length,
              //                 shrinkWrap: true,
              //                 physics: NeverScrollableScrollPhysics(),
              //                 padding: EdgeInsets.zero,
              //                 itemBuilder: (context, index) => ImportantLink(
              //                   title: impLinks[index].title!,
              //                   url: impLinks[index].url!,
              //                 ),
              //                 separatorBuilder: (context, index) => Divider(
              //                   height: 8,
              //                   thickness: 1,
              //                   color: Color(0xffEBEBEB),
              //                 ),
              //               ),
              //             ),
              //     ],
              //   ),
              // ),
              SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }
}

class ImportantLink extends StatelessWidget {
  final String title;
  final String url;
  const ImportantLink({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          SizedBox(
            width: size.width * 0.7,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.2,
                letterSpacing: -0.2,
              ),
              maxLines: 2,
            ),
          ),
          Spacer(),
          PressEffect(
            onPressed: () {
              launchUrl(
                Uri.parse(url),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Visit'.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SvgPicture.asset(
                  "assets/icons/arrow-top-right.svg",
                  height: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CheckInWidget extends ConsumerStatefulWidget {
  CheckInWidget({
    super.key,
    required this.size,
    required this.endTime,
    required this.triggerCheckIn,
    required this.checkout,
    required this.extend,
    required this.crowdedStatus,
    required this.marquee,
  });

  final Size size;
  final DateTime endTime;
  final VoidCallback triggerCheckIn;
  final VoidCallback checkout;
  final Function(int) extend;
  final CrowdStatus crowdedStatus;
  final SpaceMarquee marquee;

  @override
  _CheckInWidgetState createState() => _CheckInWidgetState();
}

class _CheckInWidgetState extends ConsumerState<CheckInWidget> {
  Duration _duration = Duration.zero;
  Timer? _timer;
  bool enableExtend = false;
  String selectedDuration = '1 hr';
  List<String> duration = [
    '1 hr',
    '2 hr',
    '3 hr',
    '4 hr',
  ];

  void _calculateDuration() {
    setState(() {
      _duration = widget.endTime.difference(DateTime.now());
      if (widget.endTime.difference(DateTime.now()).inMinutes < 15) {
        enableExtend = true;
      } else {
        enableExtend = false;
      }
    });
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (DateTime.now().isAfter(widget.endTime)) {
        widget.triggerCheckIn();
        timer.cancel();
      } else {
        if (mounted) {
          _calculateDuration();
        }
      }
    });
  }

  void checkOut() {
    widget.checkout();
  }

  @override
  void initState() {
    super.initState();
    _calculateDuration();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future _extendDialog(BuildContext context) async {
    Size size = MediaQuery.of(context).size;
    return await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      elevation: 0,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration to extend',
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: size.width,
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: duration
                          .map((e) => CheckinChip(
                                title: e,
                                selected: e == selectedDuration,
                                onTap: () {
                                  setState(() {
                                    selectedDuration = e;
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 24),
                  PressEffect(
                    onPressed: () {
                      widget.extend(int.parse(selectedDuration.split(' ')[0]));
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: size.width,
                      alignment: Alignment.center,
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Extend'.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> showCopySuccessModal() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
        color: Colors.transparent,
        child: CommonActionSheet(
          action: AppAction.Success,
          text: 'Copied to clipboard',
        ),
      ),
    );
  }

  Future<void> _showGpuAccessModal() async {
    Size size = MediaQuery.of(context).size;
    HapticFeedback.lightImpact();
    return await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      elevation: 0,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
          color: Colors.transparent,
          child: Container(
            width: size.width - 32,
            padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 12),
                        SvgPicture.asset(
                          "assets/icons/gpu_space.svg",
                          height: 32,
                        ),
                      ],
                    ),
                    Spacer(),
                    IconWrapper(
                      icon: "assets/icons/close.svg",
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'GPU access',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 32),
                _ListingContainer(
                  '1',
                  Text(
                    'Connect to TinkerSpace Jio 5G',
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                _ListingContainer(
                  '2',
                  Row(
                    children: [
                      Text(
                        'Visit  ',
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      PressEffect(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: "http://192.168.29.119"),
                          );
                          showCopySuccessModal();
                        },
                        child: Text(
                          'http://192.168.29.119',
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff189CF1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _ListingContainer(
                  '3',
                  Text(
                    'Start projects',
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGray1,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•',
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8),
                          SizedBox(
                            width: size.width * 0.68,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        'Secret portal is open exclusively for the members of ',
                                    style: TextStyle(
                                      fontFamily: 'General Sans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        launchUrl(
                                          Uri.parse(
                                              'https://github.com/tinkerhub'),
                                          mode: LaunchMode.externalApplication,
                                        );
                                      },
                                    text: 'github.com/tinkerhub',
                                    style: TextStyle(
                                      fontFamily: 'General Sans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff189CF1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•',
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8),
                          SizedBox(
                            width: size.width * 0.68,
                            child: Text(
                              "Power up your code with an RTX 4000 GPU it's in beast mode!",
                              style: TextStyle(
                                fontFamily: 'General Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•',
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8),
                          SizedBox(
                            width: size.width * 0.68,
                            child: Text(
                              "Jump right into Al with PyTorch and TensorFlow preloaded.",
                              style: TextStyle(
                                fontFamily: 'General Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showElectronicsComponentsModal() async {
    Size size = MediaQuery.of(context).size;
    HapticFeedback.lightImpact();
    return await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      elevation: 0,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
          color: Colors.transparent,
          child: Container(
            width: size.width - 32,
            padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 12),
                        SvgPicture.asset(
                          "assets/icons/electronic_space.svg",
                          height: 32,
                        ),
                      ],
                    ),
                    Spacer(),
                    IconWrapper(
                      icon: "assets/icons/close.svg",
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Electronic  components ',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Scan to locate the components. Search the component name to find out the bin in which it is located.',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 32),
                _ListingContainer(
                  '1',
                  SizedBox(
                    width: size.width * 0.65,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Find the components name from the Airtable list',
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 12),
                        PressEffect(
                          onPressed: () {
                            launchUrl(
                              Uri.parse('https://cutt.ly/zwPql7dX'),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Component list'.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'General Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 4),
                                SvgPicture.asset(
                                  "assets/icons/arrow-top-right.svg",
                                  height: 16,
                                  width: 16,
                                  colorFilter: ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _ListingContainer(
                  '2',
                  SizedBox(
                    width: size.width * 0.65,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Search the component you're looking for",
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _ListingContainer(
                  '3',
                  SizedBox(
                    width: size.width * 0.65,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Check the bin number",
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _ListingContainer(
                  '4',
                  SizedBox(
                    width: size.width * 0.65,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Open the specific bin labeled",
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _ListingContainer(
                  '5',
                  SizedBox(
                    width: size.width * 0.65,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Register the project before you start to build",
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Container _ListingContainer(String order, Widget child) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryGray1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color(0xff189CF1),
              shape: BoxShape.circle,
            ),
            child: Text(
              order,
              style: TextStyle(
                fontFamily: 'General Sans',
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
          ),
          SizedBox(width: 12),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DelayedAnimation(
      delayedAnimation: 50,
      aniOffsetX: 0,
      aniOffsetY: -0.1,
      aniDuration: 150,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.size.width * 0.9,
            margin: EdgeInsets.symmetric(horizontal: widget.size.width * 0.05),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.black,
                  width: 1,
                ),
                bottom: BorderSide(
                  color: Colors.black,
                  width: 0.5,
                ),
                left: BorderSide(
                  color: Colors.black,
                  width: 1,
                ),
                right: BorderSide(
                  color: Colors.black,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // DelayedAnimation(
                    //   delayedAnimation: 200,
                    //   aniOffsetX: 0,
                    //   aniOffsetY: -0.18,
                    //   aniDuration: 250,
                    //   child: CrowdedSpace(
                    //     status: widget.crowdedStatus,
                    //   ),
                    // ),
                    SizedBox(height: 8),
                    DelayedAnimation(
                      delayedAnimation: 250,
                      aniOffsetX: 0,
                      aniOffsetY: -0.18,
                      aniDuration: 250,
                      child: Text(
                        '${_duration.inHours < 9 ? '0${_duration.inHours}' : '${_duration.inHours}'}:${(_duration.inMinutes % 60) < 9 ? '0${_duration.inMinutes % 60}' : '${_duration.inMinutes % 60}'}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1,
                          color: Colors.black,
                          letterSpacing: 1.02,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        enableExtend
                            ? DelayedAnimation(
                                delayedAnimation: 300,
                                aniOffsetX: -0.18,
                                aniOffsetY: 0,
                                aniDuration: 250,
                                child: PressEffect(
                                  onPressed: () {
                                    _extendDialog(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'Extend'.toUpperCase(),
                                      style: TextStyle(
                                        fontFamily: 'General Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                        enableExtend ? SizedBox(width: 12) : SizedBox.shrink(),
                        DelayedAnimation(
                          delayedAnimation: 300,
                          aniOffsetX: 0,
                          aniOffsetY: -0.18,
                          aniDuration: 250,
                          child: PressEffect(
                            onPressed: checkOut,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Check-out'.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'General Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  letterSpacing: 0.24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Spacer(),
                // PressEffect(
                //   onPressed: () {
                //     Navigator.of(context).pop();
                //   },
                //   child: Text(
                //     "SPACE GUIDE",
                //     style: TextStyle(
                //       fontFamily: 'General Sans',
                //       fontSize: 12,
                //       fontWeight: FontWeight.w600,
                //       color: Colors.black,
                //     ),
                //   ),
                // ),
                // SvgPicture.asset(
                //   "assets/icons/arrow-r.svg",
                //   height: 16,
                //   width: 16,
                //   colorFilter: ColorFilter.mode(
                //     Colors.black,
                //     BlendMode.srcIn,
                //   ),
                // ),
              ],
            ),
          ),
          Container(
            width: widget.size.width * 0.9,
            margin: EdgeInsets.symmetric(horizontal: widget.size.width * 0.05),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.black,
                  width: 0.6,
                ),
                left: BorderSide(
                  color: Colors.black,
                  width: 0.6,
                ),
                right: BorderSide(
                  color: Colors.black,
                  width: 0.6,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    SpaceNav(
                      flex: 10,
                      title: 'Activities',
                      iconPath: 'assets/icons/events_space.svg',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => UpcomingEvents(
                              isSpaceEvent: true,
                            ),
                          ),
                        );
                      },
                    ),
                    SpaceNav(
                      flex: 11,
                      title: 'Need help?',
                      iconPath: 'assets/icons/help_space.svg',
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          widget.marquee.text.isNotEmpty
              ? Container(
                  width: widget.size.width * 0.9,
                  height: 38,
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  decoration: BoxDecoration(
                    color: widget.marquee.level == MarqueeLevel.info
                        ? Colors.black
                        : widget.marquee.level == MarqueeLevel.alert
                            ? Color(0xffFF0059)
                            : Color(0xff5F5CE5),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                      left: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                      right: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Marquee(
                    text:
                        "Together, we build the future: 💃Empower, 🤝🏽Volunteer, 📝Lead ✨",
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
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
