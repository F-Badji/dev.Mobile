import 'weather_model.dart';

class WeatherComparison {
  final String city1;
  final String city2;
  final WeatherModel weather1;
  final WeatherModel weather2;
  final DateTime timestamp;

  WeatherComparison({
    required this.city1,
    required this.city2,
    required this.weather1,
    required this.weather2,
    required this.timestamp,
  });

  factory WeatherComparison.fromJson(Map<String, dynamic> json) {
    return WeatherComparison(
      city1: json['city1'],
      city2: json['city2'],
      weather1: WeatherModel.fromJson(json['weather1']),
      weather2: WeatherModel.fromJson(json['weather2']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city1': city1,
      'city2': city2,
      'weather1': weather1.toJson(),
      'weather2': weather2.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  double get temperatureDiff => (weather1.temperature - weather2.temperature).abs();
  int get humidityDiff => (weather1.humidity - weather2.humidity).abs();
} 