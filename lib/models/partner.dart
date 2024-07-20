import 'dart:convert';

class Partner {
  int? id;
  int? eventId;
  int? partnerId;
  DateTime createdAt;
  DateTime updatedAt;
  String? name;
  String? description;
  String? avatar;

  Partner({
    this.id,
    this.eventId,
    this.partnerId,
    required this.createdAt,
    required this.updatedAt,
    this.name,
    this.description,
    this.avatar,
  });

  factory Partner.fromRawJson(String str) => Partner.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Partner.fromJson(Map<String, dynamic> json) => Partner(
        id: json["id"],
        eventId: json["eventId"],
        partnerId: json["partnerId"],
        createdAt: DateTime.parse(json["createdAt"]).toLocal(),
        updatedAt: DateTime.parse(json["updatedAt"]).toLocal(),
        name: json["name"],
        description: json["description"],
        avatar: json["avatar"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "eventId": eventId,
        "partnerId": partnerId,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "name": name,
        "description": description,
        "avatar": avatar,
      };
}

class PartnerContact {
  int? id;
  int? partnerId;
  String? avatar;
  String? name;
  String? title;
  String? email;
  String? phone;
  DateTime createdAt;
  DateTime updatedAt;

  PartnerContact({
    this.id,
    this.partnerId,
    this.avatar,
    this.name,
    this.title,
    this.email,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PartnerContact.fromRawJson(String str) =>
      PartnerContact.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PartnerContact.fromJson(Map<String, dynamic> json) => PartnerContact(
        id: json["id"],
        partnerId: json["partnerId"],
        name: json["name"],
        title: json["title"],
        email: json["email"],
        phone: json["phone"],
        createdAt: DateTime.parse(json["createdAt"]).toLocal(),
        updatedAt: DateTime.parse(json["updatedAt"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "partnerId": partnerId,
        "name": name,
        "title": title,
        "email": email,
        "phone": phone,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
