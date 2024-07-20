import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:equilead/models/event.dart';
import 'package:equilead/models/project.dart';
import 'package:equilead/screens/event/event.dart';
import 'package:equilead/theme/colors.dart';
import 'package:equilead/widgets/animation/delay_animation.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/empty_state.dart';
import 'package:equilead/widgets/common/project_card.dart';

class ProfileListing extends StatefulWidget {
  final List<BasicEvent>? events;
  final List<Project>? projects;
  final int minDuration;

  const ProfileListing({
    super.key,
    this.events = const [],
    this.projects = const [],
    this.minDuration = 650,
  });

  @override
  State<ProfileListing> createState() => _ProfileListingState();
}

class _ProfileListingState extends State<ProfileListing> {
  String selectedTab = 'events';
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DelayedAnimation(
                delayedAnimation: widget.minDuration,
                aniOffsetX: -0.18,
                aniOffsetY: 0,
                aniDuration: 250,
                child: TabSwitcher(
                  title: 'Events',
                  isSelected: selectedTab == 'events',
                  onTap: () {
                    setState(() {
                      selectedTab = 'events';
                    });
                  },
                ),
              ),
              SizedBox(width: 24),
              DelayedAnimation(
                delayedAnimation: widget.minDuration + 50,
                aniOffsetX: -0.18,
                aniOffsetY: 0,
                aniDuration: 250,
                child: TabSwitcher(
                  title: 'Projects',
                  isSelected: selectedTab == 'projects',
                  onTap: () {
                    setState(() {
                      selectedTab = 'projects';
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          SizedBox(
            width: size.width,
            child: ListView.separated(
              itemCount: selectedTab == 'events'
                  ? widget.events!.length
                  : widget.projects!.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                if (selectedTab == 'events') {
                  return DelayedAnimation(
                    delayedAnimation: widget.minDuration + 50 + (index * 50),
                    aniOffsetX: 0,
                    aniOffsetY: -0.18,
                    aniDuration: 250,
                    child: EventProfileCard(
                      event: widget.events![index],
                      isLast: index == widget.events!.length - 1,
                    ),
                  );
                } else {
                  return DelayedAnimation(
                    delayedAnimation: widget.minDuration + 100 + (index * 50),
                    aniOffsetX: 0,
                    aniOffsetY: -0.18,
                    aniDuration: 250,
                    child: ProjectCard(
                      title: widget.projects![index].name!,
                      description: widget.projects![index].description!,
                    ),
                  );
                }
              },
              separatorBuilder: (context, index) => SizedBox(height: 16),
            ),
          ),
          SizedBox(height: 24),
          widget.events!.isEmpty && selectedTab == 'events'
              ? DelayedAnimation(
                  delayedAnimation: widget.minDuration + 100,
                  aniOffsetX: 0,
                  aniOffsetY: -0.05,
                  aniDuration: 250,
                  child: Center(
                    child: EmptyState(
                      text:
                          "The events you've attended and organized\nwill be shown here",
                    ),
                  ),
                )
              : SizedBox.shrink(),
          widget.projects!.isEmpty && selectedTab == 'projects'
              ? DelayedAnimation(
                  delayedAnimation: widget.minDuration + 100,
                  aniOffsetX: 0,
                  aniOffsetY: -0.05,
                  aniDuration: 250,
                  child: Center(
                    child: EmptyState(
                      text: 'Coming soon! keep an eye\non this space.',
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}

class EventProfileCard extends StatelessWidget {
  const EventProfileCard({
    super.key,
    required this.event,
    this.isLast = false,
  });

  final BasicEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PressEffect(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventScreen(eventUniqueId: event.uniqueId!),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : Color(0xffEBEBEB),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: size.width * 0.6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name!,
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    event.startDate.day == event.endDate.day
                        ? DateFormat('d MMM · hh:mm a')
                                .format(event.startDate) +
                            ' - ' +
                            DateFormat('hh:mm a').format(event.endDate)
                        : DateFormat('d MMM · hh:mm a')
                                .format(event.startDate) +
                            ' - ' +
                            DateFormat('d MMM · hh:mm a').format(event.endDate),
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff575757),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
              decoration: BoxDecoration(
                color: AppColors.secondaryGray1,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                event.isAttendee
                    ? 'ATTENDED'
                    : event.isHost
                        ? 'HOSTED'
                        : 'ORGANIZED',
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TabSwitcher extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String title;

  const TabSwitcher({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.linear,
        padding: EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.black : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'General Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black : Color(0xff757575),
          ),
        ),
      ),
    );
  }
}
