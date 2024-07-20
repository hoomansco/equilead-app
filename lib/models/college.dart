import 'dart:convert';

class College {
  int? id;
  String? name;
  String? description;
  String? avatar;
  int? orgId;
  int? managerId;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? address;
  String? district;
  bool? active;
  String? website;
  String? mapUrl;

  College({
    this.id,
    this.name,
    this.description,
    this.avatar,
    this.orgId,
    this.managerId,
    this.createdAt,
    this.updatedAt,
    this.address,
    this.district,
    this.active,
    this.website,
    this.mapUrl,
  });

  factory College.fromRawJson(String str) => College.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory College.fromJson(Map<String, dynamic> json) => College(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        avatar: json["avatar"],
        orgId: json["orgId"],
        managerId: json["managerId"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        address: json["address"],
        district: json["district"],
        active: json["active"],
        website: json["website"],
        mapUrl: json["mapUrl"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "orgId": orgId,
        "address": address,
        "district": district,
        "active": active,
      };
}
