import 'dart:convert';

class Ticket {
  int id;
  int membershipId;
  int eventId;
  bool checkIn;
  DateTime createdAt;
  DateTime updatedAt;
  String ticketId;
  String eventName;
  DateTime eventStartDate;
  DateTime eventEndDate;
  String location;
  String uniqueId;

  Ticket({
    required this.id,
    required this.membershipId,
    required this.eventId,
    required this.checkIn,
    required this.createdAt,
    required this.updatedAt,
    required this.ticketId,
    required this.eventName,
    required this.eventStartDate,
    required this.eventEndDate,
    required this.location,
    required this.uniqueId,
  });

  factory Ticket.fromRawJson(String str) => Ticket.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        id: json["id"],
        membershipId: json["membershipId"],
        eventId: json["eventId"],
        checkIn: json["checkIn"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        ticketId: json["ticketId"],
        eventName: json["eventName"],
        eventStartDate: DateTime.parse(json["eventStartDate"]),
        eventEndDate: DateTime.parse(json["eventEndDate"]),
        location: json["location"],
        uniqueId: json["uniqueId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "membershipId": membershipId,
        "eventId": eventId,
        "checkIn": checkIn,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "ticketId": ticketId,
        "eventName": eventName,
        "eventStartDate": eventStartDate.toIso8601String(),
        "eventEndDate": eventEndDate.toIso8601String(),
        "location": location,
        "uniqueId": uniqueId,
      };
}
