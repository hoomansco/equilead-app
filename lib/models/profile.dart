import 'dart:convert';

import 'package:equilead/widgets/common/checkbox_group.dart';

class Profile {
  int? id;
  int? userId;
  int? orgId;
  int? subOrgId;
  int? roleId;
  int? invitedBy;
  String? name;
  String? email;
  String? avatar;
  String? bio;
  String? birthday;
  String? github;
  String? linkedin;
  String? instagram;
  String? twitter;
  String? uniqueId;
  String? sex;
  String? interests;
  bool? isStudent;
  bool? isApproved;
  bool? enableCommunication;
  String? companyName;
  String? jobType;
  String? district;
  String? stream;
  String? course;
  int? yearOfAdmission;
  int? yearOfGraduation;
  List<CheckboxItem>? skills;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? discordId;
  bool? isOnboard;

  Profile({
    this.id,
    this.userId,
    this.orgId,
    this.subOrgId = 1,
    this.roleId = 2,
    this.invitedBy,
    this.name,
    this.email,
    this.avatar = '',
    this.bio,
    this.birthday,
    this.github,
    this.linkedin,
    this.instagram,
    this.twitter,
    this.uniqueId = "XXXXXXXXXX",
    this.sex,
    this.interests,
    this.isStudent,
    this.isApproved = false,
    this.enableCommunication,
    this.companyName,
    this.jobType,
    this.district,
    this.course,
    this.stream,
    this.yearOfAdmission,
    this.yearOfGraduation,
    this.skills,
    this.discordId,
    this.isOnboard = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      userId: json['userId'],
      orgId: json['orgId'],
      subOrgId: json['subOrgId'],
      roleId: json['roleId'],
      invitedBy: json['invitedBy'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      bio: json['bio'],
      birthday: json['birthday'],
      github: json['github'],
      linkedin: json['linkedin'],
      instagram: json['instagram'],
      twitter: json['twitter'],
      uniqueId: json['uniqueId'] ?? "XXXXXXXXXX",
      sex: json['sex'],
      interests: json['interests'],
      isStudent: json['isStudent'],
      isApproved: json['isApproved'],
      enableCommunication: json['enableCommunication'],
      companyName: json['companyName'],
      jobType: json['jobType'],
      stream: json['stream'],
      course: json['course'],
      yearOfAdmission: json['yearOfAdmission'],
      yearOfGraduation: json['yearOfGraduation'],
      discordId: json['discordId'],
      isOnboard: json['isOnboard'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  factory Profile.fromRawJson(String str) => Profile.fromJson(json.decode(str));

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['orgId'] = orgId;
    data['subOrgId'] = 1;
    data['roleId'] = roleId;
    data['invitedBy'] = invitedBy;
    data['name'] = name;
    data['email'] = email;
    data['avatar'] = avatar;
    data['bio'] = bio;
    data['birthday'] = birthday;
    data['github'] = github;
    data['linkedin'] = linkedin;
    data['instagram'] = instagram;
    data['twitter'] = twitter;
    data['uniqueId'] = uniqueId;
    data['sex'] = sex;
    data['interests'] = interests;
    data['isStudent'] = isStudent;
    data['isApproved'] = isApproved;
    data['enableCommunication'] = enableCommunication;
    data['companyName'] = companyName;
    data['jobType'] = jobType;
    data['stream'] = stream;
    data['course'] = course;
    data['yearOfAdmission'] = yearOfAdmission;
    data['yearOfGraduation'] = yearOfGraduation;
    data['skills'] = {
      "data": skills != [] ? skills?.map((e) => e.toMap()).toList() : null,
    };
    data['discordId'] = discordId;
    data['isOnboard'] = isOnboard;

    return data;
  }
}

class Attendee {
  int? id;
  int? membershipId;
  String? name;
  String? avatar;
  String? college;
  String? ticketId;
  String? registrationStatus;
  bool? checkIn;
  bool? isStudent;
  String? companyName;
  String? uniqueId;
  DateTime? checkInTime;
  int? checkedInBy;

  Attendee({
    this.id,
    this.membershipId,
    this.name,
    this.avatar,
    this.uniqueId,
    this.college,
    this.ticketId,
    this.registrationStatus,
    this.checkIn,
    this.isStudent,
    this.companyName = "",
    this.checkInTime,
    this.checkedInBy,
  });

  factory Attendee.fromRawJson(String str) =>
      Attendee.fromJson(json.decode(str));

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      id: json['id'],
      membershipId: json['membershipId'],
      name: json['name'],
      avatar: json['avatar'],
      uniqueId: json['uniqueId'],
      college: json['college'],
      ticketId: json['ticketId'],
      registrationStatus: json['registrationStatus'],
      checkIn: json['checkIn'],
      isStudent: json['isStudent'],
      companyName: json['companyName'] != null ? json['companyName'] : "",
      checkInTime: json['checkInTime'] != null
          ? DateTime.parse(json['checkInTime'])
          : null,
      checkedInBy: json['checkInBy'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['membershipId'] = membershipId;
    data['name'] = name;
    data['avatar'] = avatar;
    data['uniqueId'] = uniqueId;
    data['college'] = college;
    data['ticketId'] = ticketId;
    data['registrationStatus'] = registrationStatus;
    data['checkIn'] = checkIn;
    data['isStudent'] = isStudent;
    data['companyName'] = companyName;
    data['checkInTime'] = checkInTime;
    data['checkInBy'] = checkedInBy;

    return data;
  }
}

class Organizer {
  int? id;
  int? membershipId;
  String? name;
  String? avatar;
  bool? isHost;
  String? uniqueId;

  Organizer({
    this.id,
    this.name,
    this.avatar,
    this.isHost,
    this.membershipId,
    this.uniqueId,
  });

  factory Organizer.fromRawJson(String str) =>
      Organizer.fromJson(json.decode(str));

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      id: json['id'],
      membershipId: json['membershipId'],
      name: json['name'],
      avatar: json['avatar'],
      isHost: json['isHost'],
      uniqueId: json['uniqueId'],
    );
  }
}
