import 'dart:convert';

class Vouch {
  int? id;
  int? inviterMembershipId;
  String? inviteePhoneNumber;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? inviteeMembershipId;
  String? inviteeName;
  String? inviteeAvatar;
  String? inviteeUniqueId;

  Vouch({
    this.id,
    this.inviterMembershipId,
    this.inviteePhoneNumber,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.inviteeMembershipId,
    this.inviteeName,
    this.inviteeAvatar,
    this.inviteeUniqueId,
  });

  factory Vouch.fromRawJson(String str) => Vouch.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Vouch.fromJson(Map<String, dynamic> json) => Vouch(
        id: json["id"],
        inviterMembershipId: json["inviterMembershipId"],
        inviteePhoneNumber: json["inviteePhoneNumber"],
        status: json["status"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        inviteeMembershipId: json["inviteeMembershipId"],
        inviteeName: json["inviteeName"],
        inviteeAvatar: json["inviteeAvatar"],
        inviteeUniqueId: json["inviteeUniqueId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "inviterMembershipId": inviterMembershipId,
        "inviteePhoneNumber": inviteePhoneNumber,
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "inviteeMembershipId": inviteeMembershipId,
        "inviteeName": inviteeName,
        "inviteeAvatar": inviteeAvatar,
        "inviteeUniqueId": inviteeUniqueId,
      };
}
