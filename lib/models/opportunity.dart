class Opportunity {
  final int? id;
  final String? title;
  final String? description;
  final String? location;
  final DateTime? deadline;
  final String? time;
  final String? type;
  final String? category;
  final String? mode;
  final String? companyName;
  final String? companyLogo;
  final String? companyInfo;
  final String? compensation;
  final bool? isExternal;
  final bool? isVolunteering;
  final String? externalLink;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Opportunity({
    this.id,
    this.title,
    this.description,
    this.location,
    this.deadline,
    this.time,
    this.type,
    this.category,
    this.mode,
    this.companyName,
    this.companyLogo,
    this.companyInfo,
    this.compensation,
    this.isExternal,
    this.externalLink,
    this.isVolunteering,
    this.createdAt,
    this.updatedAt,
  });

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      deadline: DateTime.parse(json['deadline']),
      time: json['time'],
      type: json['type'],
      category: json['category'],
      mode: json['mode'],
      companyName: json['companyName'],
      companyLogo: json['companyLogo'],
      companyInfo: json['companyInfo'],
      compensation: json['compensation'],
      isExternal: json['isExternal'],
      isVolunteering: json['isVolunteering'],
      externalLink: json['externalLink'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
