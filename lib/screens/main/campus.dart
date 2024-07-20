import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/models/college.dart';
import 'package:equilead/models/profile.dart';
import 'package:equilead/providers/events.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/utils/shared_prefs.dart';
import 'package:equilead/widgets/animation/delay_animation.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/event/card.dart';

class CampusPage extends ConsumerStatefulWidget {
  const CampusPage({super.key});

  @override
  _CampusPageState createState() => _CampusPageState();
}

class _CampusPageState extends ConsumerState<CampusPage> {
  bool _isLoading = true;
  bool isStudent = false;
  College college = College();
  int members = 0;
  int events = 0;
  List<Profile> campusAdmins = [];
  List<Profile> membersList = [];

  Future<void> getCampusData() async {
    if (isStudent) {
      var profile = ref.read(profileProvider);
      var resp = await NetworkUtils().httpGet("suborg/${profile.subOrgId}");
      if (resp?.statusCode == 200) {
        var campusProvider = ref.read(campusEventProvider.notifier);
        setState(() {
          college = College.fromRawJson(resp!.body);
          members = jsonDecode(resp.body)['memberCount'];
          events = jsonDecode(resp.body)['eventCount'];
          _isLoading = false;
        });
        campusProvider.getEvents(profile.subOrgId!);
        getAdmins();
        getMembers();
      }
    }
  }

  void getMembers() async {
    var profile = ref.read(profileProvider);
    var resp = await NetworkUtils()
        .httpGet("member/suborg/${profile.subOrgId}/role/4");
    if (resp?.statusCode == 200) {
      Iterable l = jsonDecode(resp!.body)["data"];
      List<Profile> members =
          List<Profile>.from(l.map((model) => Profile.fromJson(model)));
      setState(() {
        membersList = members;
      });
    }
  }

  void getAdmins() async {
    var profile = ref.read(profileProvider);
    var resp = await NetworkUtils()
        .httpGet("member/suborg/${profile.subOrgId}/role/3");
    if (resp?.statusCode == 200) {
      Iterable l = jsonDecode(resp!.body)["data"];
      List<Profile> admins =
          List<Profile>.from(l.map((model) => Profile.fromJson(model)));
      setState(() {
        campusAdmins = admins;
      });
    }
  }

  /// function to check if the user is a student or not
  void checkStudentStatus() async {
    bool student = SharedPrefs().getStudentStatus();
    setState(() {
      isStudent = student;
    });
  }

  @override
  void initState() {
    checkStudentStatus();
    getCampusData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? SizedBox(
                height: size.height,
                width: size.width,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundImage: college.avatar != null
                                ? Image.network(
                                    college.avatar!,
                                  ).image
                                : AssetImage(avatars[2]),
                          ),
                          Spacer(),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        college.name!.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            members.toString(),
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Members',
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 32),
                          Text(
                            events.toString(),
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Events',
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      ref.watch(campusEventProvider).isNotEmpty
                          ? SizedBox(height: 48)
                          : SizedBox.shrink(),
                      ref.watch(campusEventProvider).isNotEmpty
                          ? DelayedAnimation(
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
                            )
                          : SizedBox.shrink(),
                      SizedBox(height: 8),
                      SizedBox(
                        width: size.width,
                        child: ref.watch(campusEventProvider).isNotEmpty
                            ? ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: ref.read(campusEventProvider).length,
                                itemBuilder: (context, index) {
                                  var events = ref.read(campusEventProvider);
                                  return DelayedAnimation(
                                    delayedAnimation: 700 + (index * 80),
                                    aniOffsetX: 0,
                                    aniOffsetY: -0.18,
                                    aniDuration: 250,
                                    child: EventCard(
                                      index: index,
                                      eventUniqueId: events[index].uniqueId!,
                                      title: events[index].name!,
                                      coloured: false,
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
                                      featured: events[index].featured!,
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
                              )
                            : SizedBox.shrink(),
                      ),
                      SizedBox(height: 48),
                      campusAdmins.isNotEmpty
                          ? DelayedAnimation(
                              delayedAnimation: 700,
                              aniOffsetX: 0,
                              aniOffsetY: -0.18,
                              aniDuration: 250,
                              child: Text(
                                "Leadership",
                                style: TextStyle(
                                  fontFamily: 'General Sans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          : SizedBox(),
                      SizedBox(height: 16),
                      Container(
                        width: size.width * 0.9,
                        child: Wrap(
                          spacing: size.width * 0.085,
                          runSpacing: size.width * 0.055,
                          children: campusAdmins
                              .map(
                                (e) => DelayedAnimation(
                                  delayedAnimation:
                                      400 + (campusAdmins.indexOf(e) * 50),
                                  aniOffsetX: -0.18,
                                  aniOffsetY: 0,
                                  aniDuration: 250,
                                  child: PressEffect(
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      context.go('/u/${e.uniqueId}');
                                    },
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: size.width * 0.07,
                                          backgroundImage:
                                              NetworkImage(e.avatar!),
                                        ),
                                        SizedBox(height: size.width * 0.02),
                                        SizedBox(
                                          width: size.width * 0.16,
                                          child: Text(
                                            e.name!.split(" ").first,
                                            style: TextStyle(
                                              fontFamily: 'General Sans',
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
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
                      SizedBox(height: 48),
                      membersList.isNotEmpty
                          ? DelayedAnimation(
                              delayedAnimation: 700,
                              aniOffsetX: 0,
                              aniOffsetY: -0.18,
                              aniDuration: 250,
                              child: Text(
                                "All Members",
                                style: TextStyle(
                                  fontFamily: 'General Sans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          : SizedBox(),
                      SizedBox(height: 16),
                      Container(
                        width: size.width * 0.9,
                        child: Wrap(
                          spacing: size.width * 0.085,
                          runSpacing: size.width * 0.055,
                          children: membersList
                              .map(
                                (e) => DelayedAnimation(
                                  delayedAnimation:
                                      500 + (membersList.indexOf(e) * 50),
                                  aniOffsetX: -0.18,
                                  aniOffsetY: 0,
                                  aniDuration: 250,
                                  child: PressEffect(
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      context.go('/u/${e.uniqueId}');
                                    },
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: size.width * 0.07,
                                          backgroundImage:
                                              NetworkImage(e.avatar!),
                                        ),
                                        SizedBox(height: size.width * 0.02),
                                        SizedBox(
                                          width: size.width * 0.154,
                                          child: Text(
                                            e.name!.split(" ").first,
                                            style: TextStyle(
                                              fontFamily: 'General Sans',
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
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
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
