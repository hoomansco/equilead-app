import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/widgets/animation/press_effect.dart';

enum EventPersonState {
  NONE,
  REGISTRATION,
  MISSED,
  CHECKED_IN,
  ATTENTION,
  CANCELLED,
  PAUSED
}

class EventStateCard extends StatelessWidget {
  const EventStateCard({
    super.key,
    this.registrationStatus = 'applied',
    this.isInviteOnly = false,
    this.eventState = EventPersonState.REGISTRATION,
    this.onTap,
  });

  final String registrationStatus;
  final bool isInviteOnly;
  final EventPersonState eventState;
  final VoidCallback? onTap;

  String getMainText() {
    if (eventState == EventPersonState.REGISTRATION) {
      if (registrationStatus == 'applied') {
        return '';
      } else {
        return 'Thanks for registering.';
      }
    } else if (eventState == EventPersonState.CHECKED_IN) {
      return 'Awesome! \nThanks for joining us.';
    } else if (eventState == EventPersonState.CANCELLED) {
      return 'You have cancelled your registration for this event';
    } else if (eventState == EventPersonState.PAUSED) {
      return '';
    } else if (eventState == EventPersonState.MISSED) {
      return 'You missed the event';
    }
    return '';
  }

  String getSubText() {
    if (eventState == EventPersonState.REGISTRATION) {
      if (registrationStatus == 'applied') {
        return 'Your applied for this event. Wait for an invitation from the hosting team';
      } else {
        return 'Here is your event ticket';
      }
    } else if (eventState == EventPersonState.CHECKED_IN) {
      return 'Every step matters';
    } else if (eventState == EventPersonState.CANCELLED) {
      return 'This event is has been cancelled';
    } else if (eventState == EventPersonState.PAUSED) {
      return 'Registration for this event has been paused';
    } else if (eventState == EventPersonState.MISSED) {
      return 'Missing events can result in losing opportunities to attend future ones.';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return eventState == EventPersonState.NONE
        ? SizedBox.shrink()
        : Container(
            margin: EdgeInsets.only(top: 16),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: registrationStatus != 'applied' &&
                                  (eventState ==
                                          EventPersonState.REGISTRATION ||
                                      eventState == EventPersonState.CHECKED_IN)
                              ? size.width * 0.6
                              : size.width * 0.8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getMainText() != ''
                                  ? SizedBox(height: 4)
                                  : SizedBox.shrink(),
                              getMainText() != ''
                                  ? Text(
                                      getMainText(),
                                      style: TextStyle(
                                        fontFamily: 'General Sans',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        height: 1.32,
                                      ),
                                    )
                                  : SizedBox.shrink(),
                              SizedBox(height: 4),
                              Text(
                                getSubText(),
                                style: TextStyle(
                                  fontFamily: 'General Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  height: 1.32,
                                ),
                              ),
                            ],
                          ),
                        ),
                        registrationStatus != 'applied' &&
                                (eventState == EventPersonState.REGISTRATION ||
                                    eventState == EventPersonState.CHECKED_IN)
                            ? Spacer()
                            : SizedBox.shrink(),
                        registrationStatus != 'applied' &&
                                (eventState == EventPersonState.REGISTRATION ||
                                    eventState == EventPersonState.CHECKED_IN)
                            ? PressEffect(
                                onPressed: () async {
                                  HapticFeedback.lightImpact();
                                  onTap!();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  alignment: Alignment.center,
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
                                    height: 13,
                                    width: 13,
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    height: 20,
                    padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                    margin: EdgeInsets.only(
                      left: 12,
                    ),
                    decoration: BoxDecoration(
                      color: eventState == EventPersonState.REGISTRATION
                          ? registrationStatus == 'applied'
                              ? Color(0xffFFF73A)
                              : Color(0xff3CD377)
                          : eventState == EventPersonState.MISSED
                              ? Color(0xffFF0059)
                              : eventState == EventPersonState.CANCELLED
                                  ? Color(0xffFF0059)
                                  : eventState == EventPersonState.PAUSED
                                      ? Color(0xff189CF1)
                                      : Color(0xff3CD377),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      eventState == EventPersonState.REGISTRATION
                          ? registrationStatus == 'applied'
                              ? 'INVITE PENDING'
                              : isInviteOnly
                                  ? 'INVITED'
                                  : 'REGISTERED'
                          : eventState == EventPersonState.MISSED
                              ? 'MISSED'
                              : eventState == EventPersonState.CANCELLED
                                  ? 'CANCELLED'
                                  : eventState == EventPersonState.PAUSED
                                      ? 'PAUSED'
                                      : 'CHECKED-IN',
                      style: TextStyle(
                        fontFamily: 'General Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: registrationStatus == 'applied'
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
