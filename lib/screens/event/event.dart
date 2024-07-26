import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:equilead/models/event.dart';
import 'package:equilead/models/partner.dart';
import 'package:equilead/models/profile.dart';
import 'package:equilead/models/ticket.dart';
import 'package:equilead/providers/profile.dart';
import 'package:equilead/screens/event/attendees.dart';
import 'package:equilead/screens/external_profile.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/utils/network_util.dart';
import 'package:equilead/widgets/animation/delay_animation.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/action_sheet.dart';
import 'package:equilead/widgets/common/event_chip.dart';
import 'package:equilead/widgets/common/event_state.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';
import 'package:equilead/widgets/common/partner_contact.dart';
import 'package:equilead/widgets/common/rich_text.dart';
import 'package:equilead/widgets/common/swipe_confirm.dart';
import 'package:equilead/widgets/common/ticket_card.dart';
import 'package:url_launcher/url_launcher.dart';

class EventScreen extends ConsumerStatefulWidget {
  final String eventUniqueId;

  const EventScreen({
    super.key,
    required this.eventUniqueId,
  });

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  bool isLoading = true;
  bool isApplied = true;
  bool isRegisterLoading = false;
  bool isOrganizer = false;
  bool isLive = false;
  bool isCheckinActive = false;
  late Event event;
  List<Organizer> allOrganizers = [];
  List<Organizer> organizers = [];
  List<Attendee> attendees = [];
  List<Partner> partners = [];
  List<PartnerContact> partnersContacts = [];
  String registrationStatus = "incomplete";
  String? ticketId = "";
  bool isCheckedInToEvent = false;

  @override
  void initState() {
    getEventDetails();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getEventDetails() async {
    var resp =
        await NetworkUtils().httpGet("event/unique/${widget.eventUniqueId}");

    if (resp?.statusCode == 200) {
      event = Event.fromJson(jsonDecode(resp!.body)["event"]);
      var properties = {
        "featured": event.featured,
        "External": event.location,
        "Name": event.name,
        "Date": event.startDate.day == event.endDate.day
            ? DateFormat('d MMM · hh:mm a').format(event.startDate) +
                ' - ' +
                DateFormat('hh:mm a').format(event.endDate)
            : DateFormat('d MMM · hh:mm a').format(event.startDate) +
                ' - ' +
                DateFormat('d MMM · hh:mm a').format(event.endDate),
        "Online": event.isVirtual,
        "format": event.type,
        "type": event.isInviteOnly == true ? "Invite Only" : "Public",
        "partners": partners
      };

      if (json.decode(resp.body)["organizers"]["status"]) {
        Iterable o = json.decode(resp.body)["organizers"]["organizers"];
        allOrganizers =
            List<Organizer>.from(o.map((model) => Organizer.fromJson(model)));
        organizers = allOrganizers.where((element) => element.isHost!).toList();

        var profile = ref.read(profileProvider);
        if (allOrganizers
            .map((e) => e.membershipId)
            .toList()
            .contains(profile.id)) {
          setState(() {
            isOrganizer = true;
          });
        }
      }

      if (json.decode(resp.body)["attendees"]["status"]) {
        Iterable a = json.decode(resp.body)["attendees"]["attendees"];
        attendees =
            List<Attendee>.from(a.map((model) => Attendee.fromJson(model)))
                .where((e) => e.registrationStatus != "applied")
                .toList();
      }

      if (json.decode(resp.body)["partners"]["status"]) {
        Iterable a = json.decode(resp.body)["partners"]["partners"];
        partners =
            List<Partner>.from(a.map((model) => Partner.fromJson(model)));
      }

      if (json.decode(resp.body)["partnerContacts"]["status"]) {
        Iterable a =
            json.decode(resp.body)["partnerContacts"]["partnerContacts"];
        partnersContacts = List<PartnerContact>.from(
            a.map((model) => PartnerContact.fromJson(model)));
      }

      if (partners.isNotEmpty) {
        properties["partners"] = partners.map((e) => e.toJson()).toList();
      }

      if (event.startDate.isBefore(DateTime.now()) &&
          event.endDate.isAfter(DateTime.now())) {
        setState(() {
          isLive = true;
        });
      }

      if (event.startDate
              .subtract(Duration(hours: 1))
              .isBefore(DateTime.now()) &&
          event.endDate.add(Duration(hours: 2)).isAfter(DateTime.now())) {
        setState(() {
          isCheckinActive = true;
        });
      }

      setState(() {
        isLoading = false;
      });
      getRegistrationStatus();
    } else {
      await showEventFetchErrorModal();
    }
  }

  Future getRegistrationStatus() async {
    var profile = ref.read(profileProvider);

    var resp =
        await NetworkUtils().httpGet("event/rstatus/${event.id}/${profile.id}");
    if (resp?.statusCode == 200) {
      var status = jsonDecode(resp!.body);
      if (status['status'] == true) {
        setState(() {
          isApplied = true;
          var attendee = Attendee.fromJson(status['data']);
          ticketId = attendee.ticketId;
          isCheckedInToEvent = attendee.checkIn!;
          registrationStatus = attendee.registrationStatus == null
              ? "incomplete"
              : attendee.registrationStatus!;
        });
      } else {
        setState(() {
          isApplied = false;
        });
      }
    } else {
      setState(() {
        isApplied = false;
      });
    }
  }

  EventPersonState getPersonState() {
    if (event.status == 'cancelled') {
      return EventPersonState.CANCELLED;
    } else if (isCheckedInToEvent) {
      return EventPersonState.CHECKED_IN;
    } else if (event.status == 'paused') {
      return EventPersonState.PAUSED;
    } else if (isApplied) {
      return EventPersonState.REGISTRATION;
    }

    return EventPersonState.NONE;
  }

  bool showRegisterButton() {
    if (isLoading || isOrganizer || event.endDate.isBefore(DateTime.now())) {
      return false;
    }

    if (isApplied) {
      return false;
    }

    if (event.status != 'published') {
      return false;
    }

    return true;
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
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Stack(
                children: [
                  SizedBox(
                    height: size.height,
                    width: size.width,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          PressEffect(
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              await _showFullScreenImage();
                            },
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: 218,
                                  width: size.width,
                                  child: Image.network(
                                    event.banner!,
                                    fit: BoxFit.cover,
                                    height: 218,
                                    width: size.width,
                                  ),
                                ),
                                Container(
                                  height: 218,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: [0.5, 1],
                                      colors: [
                                        Color.fromARGB(0, 254, 254, 254),
                                        Color.fromARGB(255, 254, 254, 254),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 12),
                                event.isExternal!
                                    ? DelayedAnimation(
                                        delayedAnimation: 70,
                                        aniOffsetX: 0,
                                        aniOffsetY: -0.18,
                                        aniDuration: 250,
                                        child: Container(
                                          padding:
                                              EdgeInsets.fromLTRB(8, 2, 8, 2),
                                          height: 20,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Colors.black,
                                          ),
                                          child: Text(
                                            "EXTERNAL",
                                            style: TextStyle(
                                              fontFamily: 'General Sans',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xffFFF73A),
                                              height: 1.42,
                                              letterSpacing: -0.4,
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                SizedBox(height: 8),
                                DelayedAnimation(
                                  delayedAnimation: 100,
                                  aniOffsetX: 0,
                                  aniOffsetY: -0.18,
                                  aniDuration: 250,
                                  child: SizedBox(
                                    width: size.width * 0.85,
                                    child: Text(
                                      event.name!,
                                      softWrap: true,
                                      style: TextStyle(
                                        fontFamily: 'General Sans',
                                        fontSize: 28,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        height: 1.32,
                                        letterSpacing: -0.32,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                DelayedAnimation(
                                  delayedAnimation: 200,
                                  aniOffsetX: 0,
                                  aniOffsetY: -0.18,
                                  aniDuration: 250,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        event.startDate.day == event.endDate.day
                                            ? DateFormat('d MMM · hh:mm a')
                                                    .format(event.startDate) +
                                                ' - ' +
                                                DateFormat('hh:mm a')
                                                    .format(event.endDate)
                                            : DateFormat('d MMM · hh:mm a')
                                                    .format(event.startDate) +
                                                ' - ' +
                                                DateFormat('d MMM · hh:mm a')
                                                    .format(event.endDate),
                                        style: TextStyle(
                                          fontFamily: 'General Sans',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff2E2E2E),
                                          height: 0.9,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      isLive
                                          ? Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  8, 2, 8, 2),
                                              decoration: BoxDecoration(
                                                color: Color(0xffFF0000),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Text(
                                                'LIVE',
                                                style: TextStyle(
                                                  fontFamily: 'General Sans',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  height: 1,
                                                ),
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                                partners.isEmpty
                                    ? SizedBox.shrink()
                                    : SizedBox(height: 24),
                                partners.isEmpty
                                    ? SizedBox.shrink()
                                    : DelayedAnimation(
                                        delayedAnimation: 230,
                                        aniOffsetX: 0,
                                        aniOffsetY: -0.18,
                                        aniDuration: 250,
                                        child: SizedBox(
                                          height: 24,
                                          width: size.width * 0.9,
                                          child: Wrap(
                                            spacing: size.width * 0.06,
                                            runSpacing: size.width * 0.06,
                                            children: partners
                                                .map((e) => Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              30,
                                                            ),
                                                            border: Border.all(
                                                              color: Color(
                                                                  0xffEBEBEB),
                                                              width: 0.5,
                                                            ),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                            child:
                                                                Image.network(
                                                              e.avatar!,
                                                              height: 24,
                                                              width: 24,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          e.name!,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'General Sans',
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                isOrganizer
                                    ? DelayedAnimation(
                                        delayedAnimation: 250,
                                        aniOffsetX: 0,
                                        aniOffsetY: -0.18,
                                        aniDuration: 250,
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          margin: EdgeInsets.only(top: 24),
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: size.width * 0.6,
                                                    child: Text(
                                                      "You are organizing\nthis event",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'General Sans',
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 12),
                                                  PressEffect(
                                                    onPressed: () {
                                                      HapticFeedback
                                                          .lightImpact();
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Attendees(
                                                                  event: event),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 32,
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              12, 8, 12, 8),
                                                      decoration: BoxDecoration(
                                                        color: isCheckinActive
                                                            ? Colors.white
                                                            : Colors.black,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        border: Border.all(
                                                          color: isCheckinActive
                                                              ? Colors.black
                                                              : Colors.white,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            isCheckinActive
                                                                ? 'Check-in'
                                                                : 'Manage Attendees'
                                                                    .toUpperCase(),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'General Sans',
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  isCheckinActive
                                                                      ? Colors
                                                                          .black
                                                                      : Colors
                                                                          .white,
                                                              height: 1.2,
                                                            ),
                                                          ),
                                                          SizedBox(width: 4),
                                                          isCheckinActive
                                                              ? SvgPicture
                                                                  .asset(
                                                                  "assets/icons/scan-qr.svg",
                                                                  colorFilter: ColorFilter.mode(
                                                                      Colors
                                                                          .black,
                                                                      BlendMode
                                                                          .srcIn),
                                                                  height: 24,
                                                                  width: 24,
                                                                )
                                                              : SizedBox
                                                                  .shrink(),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                ],
                                              ),
                                              SizedBox(
                                                child: Image.asset(
                                                  "assets/images/animated/woman-superhero.png",
                                                  height: 40,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                SizedBox(height: 24),
                                DelayedAnimation(
                                  delayedAnimation: 300,
                                  aniOffsetX: 0,
                                  aniOffsetY: -0.18,
                                  aniDuration: 250,
                                  child: SizedBox(
                                    width: size.width * 0.85,
                                    child: Html(
                                      data: event.description!,
                                      style: {
                                        "body": Style(margin: Margins.all(0))
                                      },
                                    ),
                                  ),
                                ),
                                DelayedAnimation(
                                  delayedAnimation: 350,
                                  aniOffsetX: 0,
                                  aniOffsetY: -0.18,
                                  aniDuration: 250,
                                  child: ChipWidget(
                                    isExternal: false,
                                    chips: [
                                      event.type!.toUpperCase(),
                                      event.isInviteOnly!
                                          ? "INVITE-ONLY"
                                          : "PUBLIC",
                                      event.isVirtual! ? "ONLINE" : "OFFLINE",
                                    ],
                                    blackBorder: false,
                                  ),
                                ),
                                !isOrganizer
                                    ? DelayedAnimation(
                                        delayedAnimation: 400,
                                        aniOffsetX: 0,
                                        aniOffsetY: -0.15,
                                        aniDuration: 250,
                                        child: EventStateCard(
                                          isInviteOnly: event.isInviteOnly!,
                                          registrationStatus:
                                              registrationStatus,
                                          eventState: getPersonState(),
                                          onTap: () async {
                                            await showTicket();
                                          },
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                event.isExternal!
                                    ? SizedBox(height: 16)
                                    : SizedBox.shrink(),
                                event.isExternal!
                                    ? DelayedAnimation(
                                        delayedAnimation: 500,
                                        aniOffsetX: 0,
                                        aniOffsetY: -0.18,
                                        aniDuration: 300,
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Color(0x338BCDF8),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text:
                                                      'This is an external event. ',
                                                  style: TextStyle(
                                                    fontFamily: 'General Sans',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                    height: 1.42,
                                                    letterSpacing: -0.2,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      'Participating in this event will not be reflected on your Equilead profile, and you will not earn any Equilead rewards or certificates for attending.',
                                                  style: TextStyle(
                                                    fontFamily: 'General Sans',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xff575757),
                                                    height: 1.42,
                                                    letterSpacing: -0.2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                organizers.isNotEmpty
                                    ? SizedBox(height: 48)
                                    : SizedBox.shrink(),
                                organizers.isNotEmpty
                                    ? DelayedAnimation(
                                        delayedAnimation: 530,
                                        aniOffsetX: 0,
                                        aniOffsetY: -0.18,
                                        aniDuration: 250,
                                        child: HeaderRichText(
                                          text1: 'Host',
                                          text2: '(s)',
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                organizers.isNotEmpty
                                    ? SizedBox(height: 16)
                                    : SizedBox.shrink(),
                                Wrap(
                                  spacing: size.width * 0.09,
                                  runSpacing: size.width * 0.06,
                                  children: organizers
                                      .map((e) => DelayedAnimation(
                                            delayedAnimation: 600 +
                                                (organizers.indexOf(e) * 50),
                                            aniOffsetX: -0.18,
                                            aniOffsetY: 0,
                                            aniDuration: 250,
                                            child: PressEffect(
                                              onPressed: () {
                                                HapticFeedback.lightImpact();
                                                // context.go('/u/${e.uniqueId}');
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ExternalProfile(
                                                      uniqueId: e.uniqueId!,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Column(
                                                children: [
                                                  CircleAvatar(
                                                    radius: size.width * 0.072,
                                                    backgroundImage:
                                                        NetworkImage(e.avatar!),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          size.width * 0.02),
                                                  SizedBox(
                                                    width: size.width * 0.15,
                                                    child: Text(
                                                      e.name!.split(" ").first,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'General Sans',
                                                        fontSize: 13.5,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                                partnersContacts.isNotEmpty
                                    ? SizedBox(height: 48)
                                    : SizedBox.shrink(),
                                partnersContacts.isNotEmpty
                                    ? DelayedAnimation(
                                        delayedAnimation: 700,
                                        aniOffsetX: 0,
                                        aniOffsetY: -0.18,
                                        aniDuration: 250,
                                        child: HeaderRichText(
                                          text1: 'Get in touch',
                                          text2: '',
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                partnersContacts.isNotEmpty
                                    ? SizedBox(height: 24)
                                    : SizedBox.shrink(),
                                partnersContacts.isNotEmpty
                                    ? SizedBox(
                                        width: size.width * 0.9,
                                        child: ListView.separated(
                                          itemCount: partnersContacts.length,
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemBuilder: (context, index) {
                                            return DelayedAnimation(
                                              delayedAnimation:
                                                  740 + (index * 40),
                                              aniOffsetX: 0,
                                              aniOffsetY: -0.18,
                                              aniDuration: 250,
                                              child: PartnerContactWidget(
                                                isSpace: false,
                                                partnerContact:
                                                    partnersContacts[index],
                                                partnerName: partners
                                                    .firstWhere((element) =>
                                                        element.partnerId ==
                                                        partnersContacts[index]
                                                            .partnerId)
                                                    .name!,
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, index) {
                                            return SizedBox(height: 16);
                                          },
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                SizedBox(height: 48),
                                DelayedAnimation(
                                  delayedAnimation: 750,
                                  aniOffsetX: 0,
                                  aniOffsetY: -0.18,
                                  aniDuration: 250,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      HeaderRichText(
                                        text1: event.isVirtual!
                                            ? 'Meeting URL'
                                            : 'Location',
                                        text2: '',
                                      ),
                                      PressEffect(
                                        onPressed: event.isVirtual!
                                            ? isApplied &&
                                                    registrationStatus ==
                                                        'registered'
                                                ? () {
                                                    HapticFeedback
                                                        .lightImpact();
                                                    launchUrl(
                                                      Uri.parse(event.meetUrl),
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  }
                                                : showJoinErrorModal
                                            : () async {
                                                HapticFeedback.lightImpact();
                                                if (await canLaunchUrl(
                                                    Uri.parse(event.mapUrl!))) {
                                                  await launchUrl(
                                                    Uri.parse(event.mapUrl!),
                                                    mode: LaunchMode
                                                        .externalApplication,
                                                  );
                                                } else {
                                                  throw 'Could not open the map.';
                                                }
                                              },
                                        child: Container(
                                          padding:
                                              EdgeInsets.fromLTRB(8, 5, 8, 4),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(35),
                                            color: Colors.white,
                                            border: Border.all(
                                              width: 1,
                                              color: event.isVirtual!
                                                  ? isApplied &&
                                                          registrationStatus ==
                                                              'registered'
                                                      ? Colors.black
                                                      : Color(0xff575757)
                                                  : Colors.black,
                                            ),
                                          ),
                                          child: Text(
                                            event.isVirtual!
                                                ? 'JOIN NOW'
                                                : 'GET DIRECTION',
                                            style: TextStyle(
                                              fontFamily: 'General Sans',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: event.isVirtual!
                                                  ? isApplied &&
                                                          registrationStatus ==
                                                              'registered'
                                                      ? Colors.black
                                                      : Color(0xff575757)
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                event.isVirtual! || event.location == null
                                    ? SizedBox.shrink()
                                    : DelayedAnimation(
                                        delayedAnimation: 780,
                                        aniOffsetX: 0,
                                        aniOffsetY: -0.18,
                                        aniDuration: 250,
                                        child: Text(
                                          event.location!,
                                          style: TextStyle(
                                            fontFamily: 'General Sans',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xff575757),
                                            height: 1.42,
                                            letterSpacing: -0.4,
                                          ),
                                        ),
                                      ),
                                SizedBox(height: 48),
                                attendees.isNotEmpty
                                    ? Row(
                                        children: [
                                          HeaderRichText(
                                            text1: event.endDate
                                                    .isBefore(DateTime.now())
                                                ? 'Attended'
                                                : 'Attending',
                                            text2: '',
                                          ),
                                          Spacer(),
                                          Container(
                                            padding:
                                                EdgeInsets.fromLTRB(8, 2, 8, 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.secondaryGray1,
                                              borderRadius:
                                                  BorderRadius.circular(35),
                                            ),
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                  "assets/icons/profile.svg",
                                                  height: 10,
                                                  width: 10,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  attendees
                                                      .where((element) => event
                                                              .endDate
                                                              .isBefore(DateTime
                                                                  .now())
                                                          ? element.checkIn ==
                                                              true
                                                          : true)
                                                      .length
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontFamily: 'General Sans',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox.shrink(),
                                attendees.isNotEmpty
                                    ? SizedBox(height: 16)
                                    : SizedBox.shrink(),
                                Container(
                                  width: size.width * 0.9,
                                  child: Wrap(
                                    spacing: size.width * 0.09,
                                    runSpacing: size.width * 0.06,
                                    children: attendees
                                        .where((element) => event.endDate
                                                .isBefore(DateTime.now())
                                            ? element.checkIn == true
                                            : true)
                                        .take(50)
                                        .map(
                                          (e) => DelayedAnimation(
                                            delayedAnimation: 800 +
                                                (attendees.indexOf(e) * 50),
                                            aniOffsetX: -0.18,
                                            aniOffsetY: 0,
                                            aniDuration: 250,
                                            child: PressEffect(
                                              onPressed: () {
                                                HapticFeedback.lightImpact();
                                                // context.go('/u/${e.uniqueId}');
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ExternalProfile(
                                                      uniqueId: e.uniqueId!,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Column(
                                                children: [
                                                  CircleAvatar(
                                                    radius: size.width * 0.072,
                                                    backgroundImage:
                                                        NetworkImage(e.avatar!),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          size.width * 0.02),
                                                  SizedBox(
                                                    width: size.width * 0.148,
                                                    child: Text(
                                                      e.name!.split(" ").first,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'General Sans',
                                                        fontSize: 13.5,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
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
                              ],
                            ),
                          ),
                          attendees.isNotEmpty
                              ? SizedBox(height: 120)
                              : SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: SafeArea(
                      child: Container(
                        width: size.width,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 4),
                        child: DelayedAnimation(
                          delayedAnimation: 300,
                          aniOffsetX: 0,
                          aniOffsetY: -0.18,
                          aniDuration: 250,
                          child: Row(
                            children: [
                              IconWrapper(
                                icon: "assets/icons/back.svg",
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context.pop(context);
                                },
                              ),
                              Spacer(),
                              IconWrapper(
                                icon: "assets/icons/share.svg",
                                onTap: () async {
                                  await Share.share(
                                    'https://app.tinkerhub.org/event/${event.uniqueId}',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        floatingActionButton: showRegisterButton()
            ? PressEffect(
                onPressed: event.isExternal!
                    ? () {
                        launchUrl(Uri.parse(event.externalEventUrl));
                      }
                    : () async {
                        await _registerConfirmModal(context);
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
                        event.isInviteOnly!
                            ? 'APPLY FOR INVITE'
                            : 'REGISTER NOW',
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      event.isExternal!
                          ? SizedBox(width: 8)
                          : SizedBox.shrink(),
                      event.isExternal!
                          ? SvgPicture.asset(
                              "assets/icons/arrow-top-right.svg",
                              height: 22,
                              width: 22,
                              colorFilter: ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              )
            : SizedBox.shrink(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Future<void> showJoinErrorModal() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
        color: Colors.transparent,
        child: CommonActionSheet(
          action: AppAction.Error,
          text: 'You have to register for the event to join the meeting.',
        ),
      ),
    );
  }

  Future<void> showEventFetchErrorModal() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
        color: Colors.transparent,
        child: CommonActionSheet(
          action: AppAction.Error,
          text: 'Unable to fetch this event.',
        ),
      ),
    );
  }

  Future<void> showTicket() async {
    Size size = MediaQuery.of(context).size;
    await showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      elevation: 0,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        color: Colors.transparent,
        child: TicketCard(
          ticket: Ticket(
            id: 1,
            membershipId: 1,
            eventId: event.id!,
            checkIn: isCheckedInToEvent,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            ticketId: ticketId!,
            eventName: event.name!,
            eventStartDate: event.startDate,
            eventEndDate: event.endDate,
            location: event.location!,
            uniqueId: event.uniqueId!,
          ),
          scaleFactor: size.width * 0.0031,
          isEventPage: true,
        ),
      ),
    );
  }

  Future<bool> registerEvent() async {
    var profile = ref.read(profileProvider);
    var resp = await NetworkUtils().httpPost(
      "event/register",
      {
        "eventId": event.id,
        "membershipId": profile.id,
        "checkIn": false,
        "registrationStatus": event.isInviteOnly! ? "applied" : "registered"
      },
    );

    if (resp?.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future _showFullScreenImage() async {
    Size size = MediaQuery.of(context).size;
    return await showAdaptiveDialog(
      context: context,
      builder: (context) => PressEffect(
        onPressed: () => context.pop(),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Container(
            height: size.width,
            width: double.infinity,
            color: Colors.black.withOpacity(0.4),
            child: SizedBox(
              height: 218,
              child: Image.network(
                event.banner!,
                fit: BoxFit.fitWidth,
                width: size.width,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _registerConfirmModal(BuildContext context) async {
    return await showModalBottomSheet(
      backgroundColor: Colors.transparent,
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
                      'Join the Adventure!',
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
                                'Confirm your spot and connect with others at',
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff2E2E2E),
                              letterSpacing: -0.2,
                              height: 1.32,
                            ),
                          ),
                          TextSpan(
                            text: ' ${event.name}',
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
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
                      title:
                          'SWIPE TO ${event.isInviteOnly! ? 'APPLY' : 'REGISTER'}',
                      onSwipe: () async {
                        setSheetState(() {
                          isRegisterLoading = true;
                        });
                        var register = await registerEvent();

                        if (register) {
                          HapticFeedback.lightImpact();
                          setSheetState(() {
                            isApplied = true;
                            isRegisterLoading = false;
                          });
                          setState(() {
                            isApplied = true;
                          });
                          await getEventDetails();
                          await Future.delayed(Duration(milliseconds: 1500),
                              () {
                            if (Navigator.canPop(newContext)) {
                              Navigator.pop(newContext);
                            }
                          });
                        } else {
                          setSheetState(() {
                            isRegisterLoading = false;
                          });
                          // unable to register
                        }
                      },
                    ),
                  ],
                ),
              ),
              isRegisterLoading
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
                  height: isApplied ? 400 : 0,
                  width: isApplied ? 600 : 0,
                  decoration: BoxDecoration(
                    color: Color(0xff3cd377),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: isApplied
                      ? Icon(
                          Icons.check,
                          size: 70,
                          color: Colors.white,
                        )
                      : SizedBox.shrink(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
