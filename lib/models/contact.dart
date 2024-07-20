class Contact {
  String? name;
  String? phoneNumber;
  String? initials;

  Contact({this.name, this.phoneNumber, this.initials});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      initials: json['initials'],
    );
  }
}
