import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:equilead/providers/events.dart';
import 'package:equilead/screens/event/past_events.dart';
import 'package:equilead/widgets/animation/delay_animation.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';
import 'package:equilead/widgets/event/card.dart';

class UpcomingEvents extends ConsumerStatefulWidget {
  final bool isSpaceEvent;

  const UpcomingEvents({super.key, this.isSpaceEvent = false});
  @override
  _UpcomingEventsState createState() => _UpcomingEventsState();
}

class _UpcomingEventsState extends ConsumerState<UpcomingEvents> {
  bool isLoading = true;
  bool isSpaceEvent = false;
  String eventTypeFilter = "";
  List<String> filterNames = [
    "Space event",
    "Bootcamp",
    "Hackathon",
    "Learning Program",
    "Project Building Program",
    "Talk Session",
    "Meetup",
  ];

  @override
  void initState() {
    setSpaceEvent();
    super.initState();
  }

  setSpaceEvent() {
    setState(() {
      isSpaceEvent = widget.isSpaceEvent;
    });

    Future.delayed(Duration(milliseconds: 1000), () {
      filterEvents();
    });
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

  void filterEvents() {
    var upcomingEventRef = ref.read(upcomingEventProvider.notifier);
    var featuredEventRef = ref.read(featuredEventProvider.notifier);
    upcomingEventRef.filterEvents(eventTypeFilter, isSpaceEvent);
    featuredEventRef.filterEvents(eventTypeFilter, isSpaceEvent);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconWrapper(
                    icon: "assets/icons/back.svg",
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 24),
                  Text(
                    "Upcoming events",
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Spacer(),
                  PressEffect(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PastEvents(),
                        ),
                      );
                    },
                    child: SvgPicture.asset(
                      "assets/icons/past.svg",
                      width: 24,
                      height: 24,
                    ),
                  )
                ],
              ),
            ),
            // SizedBox(height: 24),
            // SizedBox(
            //   width: size.width,
            //   child: SingleChildScrollView(
            //     scrollDirection: Axis.horizontal,
            //     child: Row(
            //       children: filterNames
            //           .map(
            //             (e) => DelayedAnimation(
            //               delayedAnimation:
            //                   450 + (filterNames.indexOf(e) * 50),
            //               aniOffsetX: -0.18,
            //               aniOffsetY: 0,
            //               aniDuration: 250,
            //               child: FilterChip(
            //                 isSelected: e == eventTypeFilter ||
            //                     (e == "Space event" && isSpaceEvent),
            //                 title: e,
            //                 onPressed: () {
            //                   filterEvents();
            //                   setState(() {
            //                     if (e == "Space event") {
            //                       isSpaceEvent = !isSpaceEvent;
            //                     } else {
            //                       if (eventTypeFilter == e) {
            //                         eventTypeFilter = "";
            //                       } else {
            //                         eventTypeFilter = e;
            //                       }
            //                     }
            //                     filterEvents();
            //                   });
            //                 },
            //               ),
            //             ),
            //           )
            //           .toList(),
            //     ),
            //   ),
            // ),
            ref.read(featuredEventProvider).isEmpty
                ? SizedBox.shrink()
                : SizedBox(height: 24),
            ref.read(featuredEventProvider).isEmpty
                ? SizedBox.shrink()
                : DelayedAnimation(
                    delayedAnimation: 400,
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
                  ),
            SizedBox(height: 24),
            Container(
              width: size.width,
              child: ref.watch(upcomingEventProvider).isEmpty
                  ? DelayedAnimation(
                      delayedAnimation: 600,
                      aniOffsetX: 0,
                      aniOffsetY: -0.18,
                      aniDuration: 250,
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 64, 16, 32),
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
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: ref.read(upcomingEventProvider).length,
                        itemBuilder: (context, index) {
                          var events = ref.read(upcomingEventProvider);
                          return DelayedAnimation(
                            delayedAnimation: 600 + (index * 80),
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
            ),
          ],
        ),
      ),
    );
  }
}

class FilterChip extends StatelessWidget {
  const FilterChip({
    super.key,
    this.isSelected = false,
    this.title = "",
    required this.onPressed,
  });

  final bool isSelected;
  final String title;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onPressed: onPressed,
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.black : Color(0xffEBEBEB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            isSelected ? SizedBox(width: 8) : SizedBox.shrink(),
            isSelected
                ? SvgPicture.asset("assets/icons/close.svg")
                : SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
