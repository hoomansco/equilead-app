class QuickAction {
  int? id;
  String? iconPath;
  String? title;
  String? description;
  String? action;
  String? eventAttribute;

  QuickAction({
    this.id,
    this.iconPath,
    this.title,
    this.description,
    this.action,
    this.eventAttribute,
  });

  factory QuickAction.fromJson(Map<String, dynamic> json) {
    return QuickAction(
      id: json['id'],
      iconPath: json['iconPath'],
      title: json['title'],
      description: json['description'],
      action: json['action'],
      eventAttribute: json['eventAttribute'],
    );
  }
}

class Kolambi {
  String? title;
  String? url;
  bool? video;
  String? colorHex;

  Kolambi({
    this.title,
    this.url,
    this.video,
    this.colorHex,
  });

  factory Kolambi.fromJson(Map<String, dynamic> json) {
    return Kolambi(
      title: json['title'],
      url: json['url'],
      video: json['video'],
      colorHex: json['colorHex'],
    );
  }
}

class SpaceImportantLink {
  String? title;
  String? url;

  SpaceImportantLink({
    this.title,
    this.url,
  });

  factory SpaceImportantLink.fromJson(Map<String, dynamic> json) {
    return SpaceImportantLink(
      title: json['title'],
      url: json['url'],
    );
  }
}

enum MarqueeLevel { info, alert, blue }

class SpaceMarquee {
  String text;
  MarqueeLevel? level;

  SpaceMarquee({
    this.text = "",
    this.level,
  });

  factory SpaceMarquee.fromJson(Map<String, dynamic> json) {
    return SpaceMarquee(
      text: json['text'],
      level: MarqueeLevel.values.firstWhere(
        (e) => e.toString().split('.').last == json['level'],
        orElse: () => MarqueeLevel.info,
      ),
    );
  }
}
