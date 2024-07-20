import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:equilead/models/event.dart';
import 'package:equilead/models/profile.dart';
import 'package:equilead/screens/external_profile.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/widgets/animation/delay_animation.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/app_button.dart';
import 'package:equilead/widgets/common/empty_state.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';
import 'package:equilead/screens/event/qr_scanner.dart';

class Attendees extends StatefulWidget {
  final Event event;
  const Attendees({super.key, required this.event});

  @override
  State<Attendees> createState() => _AttendeesState();
}

class _AttendeesState extends State<Attendees> {
  bool isLive = false;
  bool isCheckinActive = false;
  bool eventEnded = false;
  String filter = 'Not Checked In';
  List<Attendee> allAttendees = [];
  List<Attendee> filteredAttendees = [];

  MenuController controller = MenuController();
  ScrollController tabScrollController = ScrollController();

  @override
  void initState() {
    getEventStatus();
    getAttendees();

    super.initState();
  }

  void getEventStatus() {
    if (widget.event.startDate.isBefore(DateTime.now()) &&
        widget.event.endDate.isAfter(DateTime.now())) {
      setState(() {
        isLive = true;
      });
    }

    if (widget.event.startDate
            .subtract(Duration(hours: 1))
            .isBefore(DateTime.now()) &&
        widget.event.endDate.add(Duration(hours: 2)).isAfter(DateTime.now())) {
      setState(() {
        isCheckinActive = true;
      });
    }

    if (widget.event.endDate.add(Duration(hours: 2)).isBefore(DateTime.now())) {
      setState(() {
        eventEnded = true;
      });
    }
  }

  void getAttendees() async {
    var resp =
        await NetworkUtils().httpGet('event/attendees/${widget.event.id}');
    if (resp?.statusCode == 200) {
      var data = resp?.body;
      if (json.decode(data!)['status']) {
        Iterable l = json.decode(data)['data'];
        List<Attendee> attendees =
            List<Attendee>.from(l.map((model) => Attendee.fromJson(model)))
                .toList();
        setState(() {
          allAttendees = attendees;
          filteredAttendees = attendees;
        });
        filterAttendees();
      }
    }
  }

  void filterAttendees() {
    if (filter == 'All') {
      setState(() {
        filteredAttendees = allAttendees;
      });
    } else if (filter == 'Checked In') {
      setState(() {
        filteredAttendees =
            allAttendees.where((element) => element.checkIn == true).toList();
      });
    } else if (filter == 'Not Checked In') {
      setState(() {
        filteredAttendees = allAttendees
            .where((element) =>
                element.checkIn == false &&
                element.registrationStatus == 'registered')
            .toList();
      });
    } else if (filter == 'Requests') {
      setState(() {
        filteredAttendees = allAttendees
            .where((element) => element.registrationStatus == 'applied')
            .toList();
      });
    }
  }

  Future<void> acceptInviteOfAttendee(Attendee attendee) async {
    var resp = await NetworkUtils().httpPut(
      'event/attendee/registration/status',
      {
        ...attendee.toJson(),
        "registrationStatus": "registered",
      },
    );
    if (resp?.statusCode == 200) {
      getAttendees();
      Navigator.pop(context);
    }
  }

  Future<void> showInviteModal(Attendee attendee) async {
    Size size = MediaQuery.of(context).size;
    return await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Container(
        color: Colors.transparent,
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Container(
          width: size.width,
          padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(attendee.avatar!),
              ),
              SizedBox(height: 16),
              Text(
                'Invite ${attendee.name!.split(' ')[0]}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'General Sans',
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Do you want to extend an invite to\n',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'General Sans',
                        color: Color(0xff2E2E2E),
                        height: 1.42,
                      ),
                    ),
                    TextSpan(
                      text: '${attendee.name!}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'General Sans',
                        color: Color(0xff2E2E2E),
                        height: 1.42,
                      ),
                    ),
                    TextSpan(
                      text: ' for this event?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'General Sans',
                        color: Color(0xff2E2E2E),
                        height: 1.42,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      type: ButtonType.secondary,
                      text: 'Cancel',
                    ),
                  ),
                  SizedBox(width: 32),
                  Expanded(
                    child: AppButton(
                      onPressed: () async {
                        await acceptInviteOfAttendee(attendee);
                      },
                      type: ButtonType.primary,
                      text: 'Accept',
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: size.width,
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 4, 20, 24),
              color: AppColors.secondaryGray1,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24),
                      SizedBox(
                        width: size.width * 0.7,
                        child: Text(
                          widget.event.name!,
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            height: 1.22,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            widget.event.startDate.day ==
                                    widget.event.endDate.day
                                ? DateFormat('d MMM · hh:mm a')
                                        .format(widget.event.startDate) +
                                    ' - ' +
                                    DateFormat('hh:mm a')
                                        .format(widget.event.endDate)
                                : DateFormat('d MMM · hh:mm a')
                                        .format(widget.event.startDate) +
                                    ' - ' +
                                    DateFormat('d MMM · hh:mm a')
                                        .format(widget.event.endDate),
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff2E2E2E),
                              height: 1.18,
                            ),
                          ),
                          SizedBox(width: 12),
                          // isLive
                          //     ? Container(
                          //         padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                          //         decoration: BoxDecoration(
                          //           color: Color(0xffFF0000),
                          //           borderRadius: BorderRadius.circular(30),
                          //         ),
                          //         child: Text(
                          //           'LIVE',
                          //           style: TextStyle(
                          //             fontFamily: 'General Sans',
                          //             fontSize: 12,
                          //             fontWeight: FontWeight.w600,
                          //             color: Colors.white,
                          //             height: 1,
                          //           ),
                          //         ),
                          //       )
                          //     : SizedBox.shrink(),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  IconWrapper(
                    icon: "assets/icons/x-close.svg",
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: size.width,
              padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: tabScrollController,
                    child: Row(
                      children: [
                        // FilterSelector(
                        //   isSelected: filter == 'All',
                        //   text: 'All',
                        //   onPressed: () {
                        //     setState(() {
                        //       filter = 'All';
                        //     });
                        //     filterAttendees();
                        //   },
                        //   count: filteredAttendees.length.toString(),
                        // ),
                        FilterSelector(
                          isSelected: filter == 'Not Checked In',
                          text: 'Not checked-in',
                          onPressed: () {
                            tabScrollController.animateTo(
                              tabScrollController.position.minScrollExtent,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease,
                            );
                            setState(() {
                              filter = 'Not Checked In';
                            });
                            filterAttendees();
                          },
                          count: allAttendees
                              .where((element) =>
                                  element.checkIn == false &&
                                  element.registrationStatus == 'registered')
                              .length
                              .toString(),
                        ),
                        FilterSelector(
                          isSelected: filter == 'Checked In',
                          text: 'Checked-in',
                          onPressed: () {
                            setState(() {
                              filter = 'Checked In';
                            });
                            filterAttendees();
                          },
                          count: allAttendees
                              .where((element) => element.checkIn == true)
                              .length
                              .toString(),
                        ),

                        widget.event.isInviteOnly!
                            ? FilterSelector(
                                isSelected: filter == 'Requests',
                                text: 'Requests',
                                onPressed: () {
                                  tabScrollController.animateTo(
                                    tabScrollController
                                        .position.maxScrollExtent,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.ease,
                                  );
                                  setState(() {
                                    filter = 'Requests';
                                  });
                                  filterAttendees();
                                },
                                count: allAttendees
                                    .where((element) =>
                                        element.registrationStatus == 'applied')
                                    .length
                                    .toString(),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: size.width,
                    child: filteredAttendees.isEmpty
                        ? DelayedAnimation(
                            delayedAnimation: 100,
                            aniOffsetX: 0,
                            aniOffsetY: -0.05,
                            aniDuration: 250,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.15,
                              ),
                              child: EmptyState(
                                text: "No one here yet",
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: filteredAttendees.length,
                            itemBuilder: (context, index) {
                              var attendee = filteredAttendees[index];
                              return DelayedAnimation(
                                delayedAnimation: 100 + (index * 50),
                                aniOffsetX: 0,
                                aniOffsetY: -0.18,
                                aniDuration: 250,
                                child: PressEffect(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ExternalProfile(
                                          uniqueId: attendee.uniqueId!,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage:
                                              NetworkImage(attendee.avatar!),
                                        ),
                                        SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              attendee.name!,
                                              style: TextStyle(
                                                fontFamily: 'General Sans',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                                height: 1.22,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              attendee.registrationStatus ==
                                                      'applied'
                                                  ? 'Not Invited'
                                                  : attendee.checkIn!
                                                      ? 'Checked In'
                                                      : 'Not Checked In',
                                              style: TextStyle(
                                                fontFamily: 'General Sans',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xff2E2E2E),
                                                height: 1.18,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        filter == 'Requests'
                                            ? PressEffect(
                                                onPressed: eventEnded
                                                    ? () {}
                                                    : () {
                                                        showInviteModal(
                                                            attendee);
                                                      },
                                                child: Container(
                                                  height: 25,
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.fromLTRB(
                                                      12, 8, 12, 8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    border: Border.all(
                                                      color: eventEnded
                                                          ? Color(0xffA3A3A3)
                                                          : Colors.black,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'ACCEPT',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'General Sans',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: eventEnded
                                                          ? Color(0xffA3A3A3)
                                                          : Colors.black,
                                                      height: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return DelayedAnimation(
                                delayedAnimation: 150 + (index * 50),
                                aniOffsetX: 0,
                                aniOffsetY: -0.18,
                                aniDuration: 250,
                                child: Divider(
                                  thickness: 1,
                                  color: Color(0xffEBEBEB),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: isCheckinActive
          ? PressEffect(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRCodeScanner(
                      eventId: widget.event.id!,
                      onPop: () => getAttendees(),
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Check-In',
                      style: TextStyle(
                        fontFamily: 'General Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    SvgPicture.asset(
                      "assets/icons/scan-qr.svg",
                      colorFilter:
                          ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      height: 20,
                      width: 20,
                    ),
                  ],
                ),
              ),
            )
          : SizedBox.shrink(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class FilterSelector extends StatelessWidget {
  final bool isSelected;
  final String text;
  final VoidCallback onPressed;
  final String count;
  const FilterSelector({
    super.key,
    required this.isSelected,
    required this.text,
    required this.onPressed,
    this.count = '',
  });

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onPressed: onPressed,
      child: Container(
        height: 31,
        margin: EdgeInsets.only(right: 24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: isSelected
              ? Border(
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                height: 1,
              ),
            ),
            SizedBox(width: 4),
            count != '0'
                ? Container(
                    height: 20,
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color:
                          isSelected ? Colors.black : AppColors.secondaryGray1,
                    ),
                    child: Text(
                      count,
                      style: TextStyle(
                        fontFamily: 'General Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Color(0xff2E2E2E),
                        height: 1,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
