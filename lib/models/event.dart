import 'dart:convert';

class Event {
  int? id;
  String? name;
  String? type;
  String? description;
  DateTime startDate;
  DateTime endDate;
  String? banner;
  int? orgId;
  dynamic subOrgId;
  DateTime createdAt;
  DateTime updatedAt;
  bool? featured;
  String? uniqueId;
  bool? campusExclusive;
  String? location;
  String? mapUrl;
  String? status;
  bool? isInviteOnly;
  bool? isVirtual;
  bool? isLimitedSeats;
  int? numberOfSeats;
  int? seatsAvailable;
  bool? isExternal;
  bool? isSpace;
  bool? isProjectBased;
  dynamic meetUrl;
  dynamic projectSubmissionDeadline;
  bool? allowNonGithubLinks;
  bool? isTeamProjectSubmission;
  dynamic externalEventUrl;

  Event({
    this.id,
    this.name,
    this.type,
    this.description,
    required this.startDate,
    required this.endDate,
    this.banner,
    this.orgId,
    this.subOrgId,
    required this.createdAt,
    required this.updatedAt,
    this.featured,
    this.uniqueId,
    this.campusExclusive,
    this.location,
    this.mapUrl,
    this.status,
    this.isInviteOnly,
    this.isVirtual,
    this.isLimitedSeats,
    this.numberOfSeats,
    this.seatsAvailable,
    this.isExternal,
    this.isSpace,
    this.isProjectBased,
    this.meetUrl,
    this.projectSubmissionDeadline,
    this.allowNonGithubLinks,
    this.isTeamProjectSubmission,
    this.externalEventUrl,
  });

  factory Event.fromRawJson(String str) => Event.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json["id"],
        name: json["name"],
        type: json["type"].toString().split('_').join(' '),
        description: json["description"],
        startDate: DateTime.parse(json["startDate"]).toLocal(),
        endDate: DateTime.parse(json["endDate"]).toLocal(),
        banner: json["banner"],
        orgId: json["orgId"],
        subOrgId: json["subOrgId"],
        createdAt: DateTime.parse(json["createdAt"]).toLocal(),
        updatedAt: DateTime.parse(json["updatedAt"]).toLocal(),
        featured: json["featured"],
        uniqueId: json["uniqueId"],
        campusExclusive: json["campusExclusive"],
        location: json["location"],
        mapUrl: json["mapUrl"],
        status: json["status"],
        isInviteOnly: json["isInviteOnly"],
        isVirtual: json["isVirtual"],
        isLimitedSeats: json["isLimitedSeats"],
        numberOfSeats: json["numberOfSeats"],
        seatsAvailable: json["seatsAvailable"],
        isExternal: json["isExternal"],
        isSpace: json["isSpace"],
        isProjectBased: json["isProjectBased"],
        meetUrl: json["meetUrl"],
        projectSubmissionDeadline: json["projectSubmissionDeadline"],
        allowNonGithubLinks: json["allowNonGithubLinks"],
        isTeamProjectSubmission: json["isTeamProjectSubmission"],
        externalEventUrl: json["externalEventUrl"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "description": description,
        "startDate": startDate.toIso8601String(),
        "endDate": endDate.toIso8601String(),
        "banner": banner,
        "orgId": orgId,
        "subOrgId": subOrgId,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "featured": featured,
        "uniqueId": uniqueId,
        "campusExclusive": campusExclusive,
        "location": location,
        "mapUrl": mapUrl,
        "status": status,
        "isInviteOnly": isInviteOnly,
        "isVirtual": isVirtual,
        "isLimitedSeats": isLimitedSeats,
        "numberOfSeats": numberOfSeats,
        "seatsAvailable": seatsAvailable,
        "isExternal": isExternal,
        "isSpace": isSpace,
        "isProjectBased": isProjectBased,
        "meetUrl": meetUrl,
        "projectSubmissionDeadline": projectSubmissionDeadline,
        "allowNonGithubLinks": allowNonGithubLinks,
        "isTeamProjectSubmission": isTeamProjectSubmission,
        "externalEventUrl": externalEventUrl,
      };
}

class BasicEvent {
  int? id;
  String? name;
  DateTime startDate;
  DateTime endDate;
  String? uniqueId;
  bool isHost;
  bool isAttendee;

  BasicEvent({
    this.id,
    this.name,
    required this.startDate,
    required this.endDate,
    this.uniqueId,
    this.isHost = false,
    this.isAttendee = false,
  });

  factory BasicEvent.fromRawJson(String str) =>
      BasicEvent.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BasicEvent.fromJson(Map<String, dynamic> json) => BasicEvent(
        id: json["id"],
        name: json["name"],
        startDate: DateTime.parse(json["startDate"]).toLocal(),
        endDate: DateTime.parse(json["endDate"]).toLocal(),
        uniqueId: json["uniqueId"],
        isHost: json["isHost"] ?? false,
        isAttendee: json["isAttendee"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "startDate": startDate.toIso8601String(),
        "endDate": endDate.toIso8601String(),
        "uniqueId": uniqueId,
        "isHost": isHost,
        "isAttendee": isAttendee,
      };
}

enum EventType {
  Bootcamp,
  Hackathon,
  LearningProgram,
  ProjectBuildingProgram,
  TalkSession,
  Meetup
}

enum EventMode { Online, Offline }
