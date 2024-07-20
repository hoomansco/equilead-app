class Interest {
  String name;
  String icon;
  bool selected;

  Interest({
    required this.name,
    required this.icon,
    this.selected = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'selected': selected,
    };
  }

  factory Interest.fromMap(Map<String, dynamic> map) {
    return Interest(
      name: map['name'],
      icon: map['icon'],
    );
  }
}
