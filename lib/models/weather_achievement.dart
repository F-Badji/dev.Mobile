class WeatherAchievement {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime unlockedAt;
  final String icon;

  WeatherAchievement({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.unlockedAt,
    required this.icon,
  });

  factory WeatherAchievement.fromJson(Map<String, dynamic> json) {
    return WeatherAchievement(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      unlockedAt: DateTime.parse(json['unlockedAt']),
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'unlockedAt': unlockedAt.toIso8601String(),
      'icon': icon,
    };
  }
} 