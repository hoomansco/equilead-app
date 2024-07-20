import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/constants.dart';
import 'package:equilead/screens/event/event.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/event_chip.dart';

class EventCard extends StatelessWidget {
  final int index;
  final bool featured;
  final String title;
  final String date;
  final String? location;
  final String eventUniqueId;
  final String type;
  final String? image;
  final bool isInviteOnly;
  final bool isExternal;
  final bool isVirtual;
  final bool coloured;
  final bool? horizontalPadding;
  final bool fullWidth;

  const EventCard({
    super.key,
    required this.featured,
    required this.index,
    required this.title,
    required this.eventUniqueId,
    required this.coloured,
    required this.date,
    required this.type,
    this.location,
    required this.isInviteOnly,
    required this.isVirtual,
    required this.isExternal,
    this.image,
    this.horizontalPadding,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PressEffect(
      onPressed: eventUniqueId != ""
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventScreen(
                    eventUniqueId: eventUniqueId,
                  ),
                ),
              );
            }
          : () {},
      child: Container(
        width: fullWidth ? size.width - 40 : size.width * 0.78,
        margin: EdgeInsets.only(left: (index == 0 && coloured) ? 20 : 0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: coloured ? Colors.black : Colors.transparent,
            width: coloured ? 0.6 : 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: horizontalPadding != null ? 16 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.68,
                        height: 55,
                        child: Text(
                          title,
                          maxLines: 2,
                          softWrap: true,
                          style: TextStyle(
                            fontFamily: 'General Sans',
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            height: 1.42,
                            letterSpacing: -0.32,
                          ),
                        ),
                      ),
                      Spacer(),
                      coloured
                          ? SizedBox.shrink()
                          : SvgPicture.asset(eventIcons[index % 9])
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    date,
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 0.9,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                  ),
                  isVirtual || location == ""
                      ? SizedBox.shrink()
                      : SizedBox(height: 16),
                  isVirtual || location == ""
                      ? SizedBox(height: 16)
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset('assets/icons/location.svg'),
                            SizedBox(width: 4),
                            SizedBox(
                              width: size.width * 0.62,
                              child: Text(
                                location!,
                                style: TextStyle(
                                  fontFamily: 'General Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff575757),
                                  height: 1,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                  SizedBox(height: 16),
                  ChipWidget(
                    isExternal: false,
                    chips: [
                      type.toUpperCase(),
                      isInviteOnly ? "INVITE-ONLY" : "PUBLIC",
                      isVirtual ? "ONLINE" : "OFFLINE",
                    ],
                    blackBorder: coloured,
                  )
                ],
              ),
            ),
            image != null
                ? SizedBox(
                    height: 160,
                    width: size.width,
                    child: Image.network(
                      image!,
                      fit: BoxFit.cover,
                      height: 168,
                      width: size.width,
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
