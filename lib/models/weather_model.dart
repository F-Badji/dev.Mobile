class WeatherModel {
  final String city;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String windDirection;
  final String description;
  final String icon;
  final double pressure;
  final int visibility;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.description,
    required this.icon,
    required this.pressure,
    required this.visibility,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['name'] ?? '',
      temperature: (json['main']?['temp'] ?? 0.0).toDouble(),
      feelsLike: (json['main']?['feels_like'] ?? 0.0).toDouble(),
      humidity: json['main']?['humidity'] ?? 0,
      windSpeed: (json['wind']?['speed'] ?? 0.0).toDouble(),
      windDirection: _getWindDirection(json['wind']?['deg'] ?? 0),
      description: json['weather']?[0]?['description'] ?? '',
      icon: json['weather']?[0]?['icon'] ?? '',
      pressure: (json['main']?['pressure'] ?? 0.0).toDouble(),
      visibility: json['visibility'] ?? 0,
      latitude: (json['coord']?['lat'] ?? 0.0).toDouble(),
      longitude: (json['coord']?['lon'] ?? 0.0).toDouble(),
      timestamp: DateTime.now(),
    );
  }

  static String _getWindDirection(int degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'N';
    if (degrees >= 22.5 && degrees < 67.5) return 'NE';
    if (degrees >= 67.5 && degrees < 112.5) return 'E';
    if (degrees >= 112.5 && degrees < 157.5) return 'SE';
    if (degrees >= 157.5 && degrees < 202.5) return 'S';
    if (degrees >= 202.5 && degrees < 247.5) return 'SO';
    if (degrees >= 247.5 && degrees < 292.5) return 'O';
    if (degrees >= 292.5 && degrees < 337.5) return 'NO';
    return 'N';
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'description': description,
      'icon': icon,
      'pressure': pressure,
      'visibility': visibility,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 