import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/models/event.dart';
import 'package:equilead/models/interests.dart';
import 'package:equilead/models/profile.dart';
import 'package:equilead/models/project.dart';
import 'package:equilead/providers/events.dart';
import 'package:equilead/screens/vouched_by.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/widgets/animation/delay_animation.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';
import 'package:equilead/widgets/common/profile_listing.dart';
import 'package:equilead/widgets/common/socials.dart';

class ExternalProfile extends ConsumerStatefulWidget {
  final String uniqueId;
  const ExternalProfile({super.key, this.uniqueId = ''});

  @override
  ExternalProfileState createState() => ExternalProfileState();
}

class ExternalProfileState extends ConsumerState<ExternalProfile> {
  bool isLoading = true;
  bool isError = false;
  String vouchedBy = '';
  String vouchedByUniqueId = '';
  String numberOfVouches = "2";
  String collegeName = '';
  Profile profile = Profile();

  List<Interest> allInterests =
      interests.map((e) => Interest.fromMap(e)).toList();
  List<Interest> selectedInterests = [];

  List<BasicEvent> profileEvents = [];
  List<Project> profileProjects = [];

  @override
  void initState() {
    super.initState();
    if (widget.uniqueId.isNotEmpty) {
      getProfile(widget.uniqueId);
    }
  }

  void getProfile(String uId) async {
    setState(() {
      isLoading = true;
      profile = Profile();
      profileEvents = [];
      profileProjects = [];
      vouchedBy = '';
      vouchedByUniqueId = '';
    });
    var resp = await NetworkUtils().httpGet("member/$uId");
    if (resp?.statusCode == 200) {
      var p = Profile.fromRawJson(resp!.body);
      profile = p;

      List<String> interests = p.interests!.split(',');
      selectedInterests = allInterests
          .where((element) => interests.contains(element.name.toString()))
          .toList();

      if (p.id == null) {
        setState(() {
          isError = true;
        });
      } else {
        profileEvents = [];
        profileProjects = [];
        getProfileEvents(p.id!);
        setState(() {
          vouchedBy = '';
          vouchedByUniqueId = '';
        });
        if (p.id != null && p.invitedBy != null) {
          getVouchDetails();
        }

        if (p.subOrgId != null) {
          getCollege();
        }
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  void getProfileEvents(int id) async {
    var resp = await NetworkUtils().httpGet('event/member/$id');
    if (resp?.statusCode == 200) {
      var data = jsonDecode(resp!.body);
      if (data['organized']['status']) {
        Iterable l = json.decode(resp.body)['organized']["data"];
        List<BasicEvent> events =
            List<BasicEvent>.from(l.map((model) => BasicEvent.fromJson(model)));
        events.forEach((element) {
          element.isAttendee = false;
        });
        setState(() {
          profileEvents = events;
        });
      }
      if (data['attended']['status']) {
        Iterable l = json.decode(resp.body)['attended']["data"];
        List<BasicEvent> events =
            List<BasicEvent>.from(l.map((model) => BasicEvent.fromJson(model)));
        events.forEach((element) {
          element.isAttendee = true;
        });
        setState(() {
          profileEvents = [...profileEvents, ...events];
          profileEvents.sort((a, b) => b.startDate.compareTo(a.startDate));
        });
      }
    }
  }

  void getVouchDetails() async {
    var resp = await NetworkUtils().httpGet('member/invite/u/${profile.id}');
    var countResp =
        await NetworkUtils().httpGet('member/invite/m/${profile.id}');
    if (resp?.statusCode == 200) {
      var data = jsonDecode(resp!.body);
      if (data != null) {
        setState(() {
          vouchedBy = data['inviterName'];
          vouchedByUniqueId = data['inviterUniqueId'];
        });
      } else {
        setState(() {
          vouchedBy = '';
          vouchedByUniqueId = '';
        });
      }
    } else {
      setState(() {
        vouchedBy = '';
        vouchedByUniqueId = '';
      });
    }
    if (countResp?.statusCode == 200) {
      var countData = jsonDecode(countResp!.body);
      if (countData["status"]) {
        setState(() {
          numberOfVouches = countData['data'].length.toString();
        });
      } else {
        setState(() {
          numberOfVouches = "";
        });
      }
    } else {
      setState(() {
        numberOfVouches = "";
      });
    }
  }

  void getCollege() async {
    var resp = await NetworkUtils().httpGet('suborg/${profile.subOrgId}');
    if (resp?.statusCode == 200) {
      var data = jsonDecode(resp!.body);
      if (data != null) {
        setState(() {
          collegeName = data['name'];
        });
      }
    }
  }

  void getEvents() async {
    var upcomingEventRef = ref.read(upcomingEventProvider.notifier);
    var featuredEventRef = ref.read(featuredEventProvider.notifier);
    await upcomingEventRef.getEvents();
    await featuredEventRef.getEvents();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          getEvents();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DelayedAnimation(
                              delayedAnimation: 400,
                              aniOffsetX: -0.2,
                              aniOffsetY: 0,
                              aniDuration: 250,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: profile.avatar == null
                                    ? Image.asset(
                                            avatars[(profile.id! % 7) - 1])
                                        .image
                                    : Image.network(
                                        profile.avatar!,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ).image,
                              ),
                            ),
                            Spacer(),
                            DelayedAnimation(
                              delayedAnimation: 700,
                              aniOffsetX: -0.2,
                              aniOffsetY: 0,
                              aniDuration: 250,
                              child: IconWrapper(
                                icon: "assets/icons/x-close.svg",
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        DelayedAnimation(
                          delayedAnimation: 450,
                          aniOffsetX: 0,
                          aniOffsetY: -0.18,
                          aniDuration: 250,
                          child: Row(
                            children: [
                              Text(
                                profile.name!.toUpperCase(),
                                maxLines: 2,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: profile.name!.length > 20 ? 20 : 24,
                                  fontFamily: 'General Sans',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              SizedBox(width: 4),
                              profile.isApproved!
                                  ? SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: Image.asset(
                                        'assets/icons/verified.png',
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        DelayedAnimation(
                          delayedAnimation: 500,
                          aniOffsetX: 0,
                          aniOffsetY: -0.18,
                          aniDuration: 250,
                          child: Text(
                            profile.subOrgId == null
                                ? '${profile.jobType != "Others" ? profile.jobType : ""}${profile.jobType != "Others" ? " at " : ''}${profile.companyName}'
                                : collegeName,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.68),
                              fontSize: 14,
                              fontFamily: 'General Sans',
                              fontWeight: FontWeight.w500,
                              height: 1,
                              letterSpacing: -0.28,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        DelayedAnimation(
                          delayedAnimation: 550,
                          aniOffsetX: 0,
                          aniOffsetY: -0.18,
                          aniDuration: 250,
                          child: Text(
                            profile.bio!,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'General Sans',
                              fontWeight: FontWeight.w300,
                              height: 1.42,
                              letterSpacing: 0.20,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: size.width - 48,
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: selectedInterests
                                .map(
                                  (e) => DelayedAnimation(
                                    delayedAnimation:
                                        600 + selectedInterests.indexOf(e) * 50,
                                    aniOffsetX: -0.18,
                                    aniOffsetY: 0,
                                    aniDuration: 300,
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: AppColors.secondaryGray1,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset(
                                            e.icon,
                                            height: 14,
                                            width: 14,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            e.name.toUpperCase(),
                                            style: TextStyle(
                                              fontFamily: 'General Sans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              height: 0.9,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            profile.github != null && profile.github!.isNotEmpty
                                ? DelayedAnimation(
                                    delayedAnimation: 700,
                                    aniOffsetX: -0.18,
                                    aniOffsetY: 0,
                                    aniDuration: 250,
                                    child: SocialLinks(
                                      icon: SocialIcon.GitHub,
                                      url: profile.github!.contains('/')
                                          ? profile.github
                                          : 'https://github.com/${profile.github}',
                                    ),
                                  )
                                : SizedBox.shrink(),
                            SizedBox(
                                width: profile.github != null &&
                                        profile.github!.isNotEmpty
                                    ? 16
                                    : 0),
                            profile.linkedin != null &&
                                    profile.linkedin!.isNotEmpty
                                ? DelayedAnimation(
                                    delayedAnimation: 750,
                                    aniOffsetX: -0.18,
                                    aniOffsetY: 0,
                                    aniDuration: 250,
                                    child: SocialLinks(
                                      icon: SocialIcon.Linkedin,
                                      url: profile.linkedin!.contains('/')
                                          ? profile.linkedin
                                          : 'https://www.linkedin.com/in/${profile.linkedin}',
                                    ),
                                  )
                                : SizedBox.shrink(),
                            SizedBox(
                                width: profile.linkedin != null &&
                                        profile.linkedin!.isNotEmpty
                                    ? 16
                                    : 0),
                            profile.twitter != null &&
                                    profile.twitter!.isNotEmpty
                                ? DelayedAnimation(
                                    delayedAnimation: 800,
                                    aniOffsetX: -0.18,
                                    aniOffsetY: 0,
                                    aniDuration: 250,
                                    child: SocialLinks(
                                      icon: SocialIcon.Twitter,
                                      url: profile.twitter!.contains('/')
                                          ? profile.twitter
                                          : 'https://x.com/${profile.twitter}',
                                    ),
                                  )
                                : SizedBox.shrink(),
                            SizedBox(
                                width: profile.twitter != null &&
                                        profile.twitter!.isNotEmpty
                                    ? 16
                                    : 0),
                            profile.instagram != null &&
                                    profile.instagram!.isNotEmpty
                                ? DelayedAnimation(
                                    delayedAnimation: 850,
                                    aniOffsetX: -0.18,
                                    aniOffsetY: 0,
                                    aniDuration: 250,
                                    child: SocialLinks(
                                      icon: SocialIcon.Instagram,
                                      url: profile.instagram!.contains('/')
                                          ? profile.instagram
                                          : 'https://instagram.com/${profile.instagram}',
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                        vouchedByUniqueId.isNotEmpty
                            ? SizedBox(height: 24)
                            : SizedBox.shrink(),
                        vouchedByUniqueId.isNotEmpty
                            ? DelayedAnimation(
                                delayedAnimation: 850,
                                aniOffsetX: 0,
                                aniOffsetY: -0.18,
                                aniDuration: 250,
                                child: Row(
                                  children: [
                                    Text(
                                      'Vouched By'.toUpperCase(),
                                      style: TextStyle(
                                        fontFamily: 'General Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xffA3A3A3),
                                      ),
                                    ),
                                    PressEffect(
                                      onPressed: () {
                                        if (mounted) {
                                          getProfile(vouchedByUniqueId);
                                        }
                                      },
                                      child: Text(
                                        ' ${vouchedBy.split(" ").first.toUpperCase()}',
                                        style: TextStyle(
                                          fontFamily: 'General Sans',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    SvgPicture.asset(
                                      "assets/icons/arrow-top-right.svg",
                                    ),
                                    numberOfVouches.isNotEmpty
                                        ? Text(
                                            ' AND Vouched'.toUpperCase(),
                                            style: TextStyle(
                                              fontFamily: 'General Sans',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xffA3A3A3),
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    numberOfVouches.isNotEmpty
                                        ? PressEffect(
                                            onPressed: () {
                                              if (mounted) {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        VouchedBy(
                                                      membershipId: profile.id!
                                                          .toString(),
                                                      profileName: profile.name!
                                                          .split(" ")
                                                          .first,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Text(
                                              ' $numberOfVouches Makers'
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                fontFamily: 'General Sans',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                              ),
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              )
                            : SizedBox.shrink(),
                        SizedBox(height: 32),
                        ProfileListing(
                          events: profileEvents,
                          projects: [],
                        ),
                        SizedBox(height: 88),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
