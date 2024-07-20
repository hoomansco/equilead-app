import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:equilead/models/ticket.dart';
import 'package:equilead/screens/event/event.dart';
import 'package:equilead/widgets/common/qr.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final double scaleFactor;
  final bool? isEventPage;
  const TicketCard({
    super.key,
    required this.ticket,
    this.scaleFactor = 1.0,
    this.isEventPage = false,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 400 * scaleFactor,
      width: 280 * scaleFactor,
      margin: EdgeInsets.fromLTRB(12, 0, 12, 0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            height: 130 * scaleFactor,
            width: 280 * scaleFactor,
            padding: EdgeInsets.all(16 * scaleFactor),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12 * scaleFactor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.eventStartDate.day == ticket.eventEndDate.day
                      ? DateFormat('d MMM · hh:mm a')
                              .format(ticket.eventStartDate) +
                          ' - ' +
                          DateFormat('hh:mm a').format(ticket.eventEndDate)
                      : DateFormat('d MMM · hh:mm a')
                              .format(ticket.eventStartDate) +
                          ' - ' +
                          DateFormat('d MMM · hh:mm a')
                              .format(ticket.eventEndDate),
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff2e2e2e),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  ticket.eventName,
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 20 * scaleFactor,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff2e2e2e),
                    height: 1.32,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/location.svg",
                      width: 12 * scaleFactor,
                      height: 12 * scaleFactor,
                    ),
                    SizedBox(width: 2),
                    SizedBox(
                      width: size.width * 0.595 * scaleFactor,
                      child: Text(
                        ticket.location,
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 11 * scaleFactor,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff2e2e2e),
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: isEventPage!
                ? () {
                    Navigator.of(context).pop();
                  }
                : () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventScreen(
                            eventUniqueId: ticket.uniqueId,
                          ),
                        ),
                      )
                    },
            child: ticket.checkIn
                ? Image.asset("assets/images/ticket_used.png")
                : Image.asset("assets/images/ticket-middle.png"),
          ),
          Container(
            height: 200 * scaleFactor,
            width: 280 * scaleFactor,
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(8, 4, 8, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: QRCode(
              avatar: "",
              data: ticket.ticketId,
              size: 180 * scaleFactor,
            ),
          ),
        ],
      ),
    );
  }
}
