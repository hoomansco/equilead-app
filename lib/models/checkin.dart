import 'dart:convert';

class CheckIn {
  int? id;
  int? membershipId;
  String? purpose;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  bool? isMentor;

  CheckIn({
    this.id,
    this.membershipId,
    this.purpose,
    this.checkInTime,
    this.checkOutTime,
    this.isMentor,
  });

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['id'],
      membershipId: json['membershipId'],
      purpose: json['purpose'],
      checkInTime: json["checkInTime"] == null
          ? null
          : DateTime.parse(json['checkInTime']).toLocal(),
      checkOutTime: json["checkOutTime"] == null
          ? null
          : DateTime.parse(json['checkOutTime']).toLocal(),
      isMentor: json['isMentor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'membershipId': membershipId,
      'purpose': purpose,
      'checkInTime': checkInTime == null
          ? null
          : checkInTime!.toIso8601String() + '+05:30',
      'checkOutTime': checkOutTime == null
          ? null
          : checkOutTime!.toIso8601String() + '+05:30',
      'isMentor': isMentor,
    };
  }

  factory CheckIn.fromRawJson(String str) => CheckIn.fromJson(json.decode(str));
}
