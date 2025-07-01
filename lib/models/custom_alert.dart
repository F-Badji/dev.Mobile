enum AlertType {
  temperature,
  humidity,
  wind,
  rain,
  snow,
  uv,
  pollen,
  airQuality,
}

class CustomAlert {
  final String id;
  final String title;
  final String condition;
  final String location;
  final double threshold;
  final AlertType type;
  final bool isActive;
  final DateTime createdAt;

  CustomAlert({
    required this.id,
    required this.title,
    required this.condition,
    required this.location,
    required this.threshold,
    required this.type,
    required this.isActive,
    required this.createdAt,
  });

  factory CustomAlert.fromJson(Map<String, dynamic> json) {
    return CustomAlert(
      id: json['id'],
      title: json['title'],
      condition: json['condition'],
      location: json['location'],
      threshold: (json['threshold'] as num).toDouble(),
      type: AlertType.values.firstWhere((e) => e.toString() == 'AlertType.${json['type']}'),
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'condition': condition,
      'location': location,
      'threshold': threshold,
      'type': type.toString().split('.').last,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 