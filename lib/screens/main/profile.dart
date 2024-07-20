import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/models/event.dart';
import 'package:equilead/models/interests.dart';
import 'package:equilead/models/profile.dart';
import 'package:equilead/models/project.dart';
import 'package:equilead/providers/college.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/screens/edit_profile.dart';
import 'package:equilead/screens/settings.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/utils/shared_prefs.dart';
import 'package:equilead/widgets/animation/delay_animation.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/profile_listing.dart';
import 'package:equilead/widgets/common/qr.dart';
import 'package:equilead/widgets/common/socials.dart';

class MemberProfile extends ConsumerStatefulWidget {
  const MemberProfile({super.key});

  @override
  _MemberProfileState createState() => _MemberProfileState();
}

class _MemberProfileState extends ConsumerState<MemberProfile> {
  bool isProfileLoading = true;
  bool isVouchLoading = true;
  bool isCollegeLoading = true;
  String vouchedBy = '';
  String vouchedByUniqueId = '';
  Profile profile = Profile();

  List<Interest> allInterests =
      interests.map((e) => Interest.fromMap(e)).toList();
  List<Interest> selectedInterests = [];

  List<BasicEvent> profileEvents = [];
  List<Project> profileProjects = [];

  @override
  void initState() {
    getProfile();
    super.initState();
  }

  void refreshProfile() {
    getProfile();
  }

  void getProfile() async {
    var userId = SharedPrefs().getUserID();
    var p = await ref.read(profileProvider.notifier).getProfile(userId);
    profile = p;
    List<String> interests = p.interests!.split(',');
    print(p);
    selectedInterests = allInterests
        .where((element) => interests.contains(element.name.toString()))
        .toList();

    setState(() {
      isProfileLoading = false;
    });

    if (p.id != null) {
      getProfileEvents();
    }

    if (p.id != null && p.invitedBy != null) {
      getVouchDetails();
    }
  }

  void getVouchDetails() async {
    var phoneNumber = SharedPrefs().getPhoneNumber();
    var resp = await NetworkUtils().httpGet('invite/$phoneNumber');
    if (resp?.statusCode == 200) {
      var data = jsonDecode(resp!.body);
      if (data != null) {
        setState(() {
          vouchedBy = data['inviterName'];
          vouchedByUniqueId = data['inviterUniqueId'];
          isVouchLoading = false;
        });
      }
    }
  }

  void getProfileEvents() async {
    profileEvents = [];
    var resp = await NetworkUtils().httpGet('event/member/${profile.id}');
    if (resp?.statusCode == 200) {
      var data = jsonDecode(resp!.body);
      if (data['organized']['status']) {
        Iterable l = json.decode(resp.body)['organized']["data"];
        List<BasicEvent> events =
            List<BasicEvent>.from(l.map((model) => BasicEvent.fromJson(model)));
        events.forEach((element) {
          element.isAttendee = false;
        });
        profileEvents = [];
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isProfileLoading
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
                                  ? Image.asset(avatars[(profile.id! % 7) - 1])
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
                            delayedAnimation: 740,
                            aniOffsetX: 0,
                            aniOffsetY: -0.18,
                            aniDuration: 250,
                            child: PressEffect(
                              onPressed: () async {
                                await _qrCodeModal(
                                  context,
                                  profile.uniqueId!,
                                  profile.name!,
                                  profile.avatar,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: SvgPicture.asset('assets/icons/qr.svg'),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          DelayedAnimation(
                            delayedAnimation: 760,
                            aniOffsetX: 0,
                            aniOffsetY: -0.18,
                            aniDuration: 250,
                            child: PressEffect(
                              onPressed: () async {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Settings(),
                                  ),
                                );
                              },
                              child: SvgPicture.asset('assets/icons/cog.svg'),
                            ),
                          )
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
                                        'assets/icons/verified.png'),
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
                          !profile.isStudent!
                              ? '${profile.jobType != "Others" ? profile.jobType : ""}${profile.jobType != "Others" ? " at " : ''}${profile.companyName}'
                              : ref.watch(collegeNameProvider),
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
                      selectedInterests.isEmpty
                          ? SizedBox.shrink()
                          : SizedBox(
                              width: size.width - 48,
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: selectedInterests
                                    .map(
                                      (e) => DelayedAnimation(
                                        delayedAnimation: 600 +
                                            selectedInterests.indexOf(e) * 50,
                                        aniOffsetX: -0.18,
                                        aniOffsetY: 0,
                                        aniDuration: 300,
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
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
                          profile.twitter != null && profile.twitter!.isNotEmpty
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
                      profile.invitedBy != null
                          ? SizedBox(height: 24)
                          : SizedBox.shrink(),
                      profile.invitedBy != null
                          ? isVouchLoading
                              ? SizedBox.shrink()
                              : DelayedAnimation(
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
                                          context.go('/u/$vouchedByUniqueId');
                                        },
                                        child: Text(
                                          ' $vouchedBy'.toUpperCase(),
                                          style: TextStyle(
                                            fontFamily: 'General Sans',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      SvgPicture.asset(
                                          "assets/icons/arrow-top-right.svg")
                                    ],
                                  ),
                                )
                          : SizedBox.shrink(),
                      SizedBox(height: 24),
                      DelayedAnimation(
                        delayedAnimation: 900,
                        aniOffsetX: 0,
                        aniOffsetY: -0.18,
                        aniDuration: 250,
                        child: PressEffect(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditProfile(
                                  onPop: () => refreshProfile(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: size.width,
                            alignment: Alignment.center,
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontFamily: 'General Sans',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      ProfileListing(
                        events: profileEvents,
                        projects: [],
                      ),
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future _qrCodeModal(BuildContext context, String uniqueId, String name,
      String? avatar) async {
    Size size = MediaQuery.of(context).size;
    return await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Container(
        width: size.width,
        height: size.width * 1.14,
        padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Container(
          width: size.width * 0.95,
          padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              QRCode(
                size: size.width * 0.8,
                data: "https://app.tinkerhub.org/u/$uniqueId",
                avatar: avatar ?? "",
              ),
              SizedBox(height: 16),
              Text(
                name.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
