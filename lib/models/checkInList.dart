import 'dart:convert';

class CheckInList {
  int? mid;
  int? id;
  int? membershipId;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  String? purpose;
  bool? isMentor;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? name;
  String? avatar;
  int? roleId;
  String? role;

  CheckInList({
    this.mid,
    this.id,
    this.membershipId,
    this.checkInTime,
    this.checkOutTime,
    this.purpose,
    this.isMentor,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.avatar,
    this.roleId,
    this.role,
  });

  factory CheckInList.fromRawJson(String str) =>
      CheckInList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CheckInList.fromJson(Map<String, dynamic> json) => CheckInList(
        mid: json["mid"],
        id: json["id"],
        membershipId: json["membershipId"],
        checkInTime: json["checkInTime"] == null
            ? null
            : DateTime.parse(json["checkInTime"]),
        checkOutTime: json["checkOutTime"] == null
            ? null
            : DateTime.parse(json["checkOutTime"]),
        purpose: json["purpose"],
        isMentor: json["isMentor"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        name: json["name"],
        avatar: json["avatar"],
        roleId: json["roleId"],
        role: json["role"],
      );

  Map<String, dynamic> toJson() => {
        "mid": mid,
        "id": id,
        "membershipId": membershipId,
        "checkInTime": checkInTime?.toIso8601String(),
        "checkOutTime": checkOutTime?.toIso8601String(),
        "purpose": purpose,
        "isMentor": isMentor,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "name": name,
        "avatar": avatar,
        "roleId": roleId,
        "role": role,
      };
}
