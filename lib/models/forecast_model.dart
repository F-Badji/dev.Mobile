class HourlyForecast {
  final DateTime dateTime;
  final double temperature;
  final String icon;

  HourlyForecast({
    required this.dateTime,
    required this.temperature,
    required this.icon,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: true),
      temperature: (json['temp'] ?? 0.0).toDouble(),
      icon: json['weather']?[0]?['icon'] ?? '',
    );
  }
}

class DailyForecast {
  final DateTime dateTime;
  final double minTemp;
  final double maxTemp;
  final String icon;

  DailyForecast({
    required this.dateTime,
    required this.minTemp,
    required this.maxTemp,
    required this.icon,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: true),
      minTemp: (json['temp']?['min'] ?? 0.0).toDouble(),
      maxTemp: (json['temp']?['max'] ?? 0.0).toDouble(),
      icon: json['weather']?[0]?['icon'] ?? '',
    );
  }
}

class ForecastModel {
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  ForecastModel({required this.hourly, required this.daily});

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final hourly = (json['hourly'] as List?)?.map((e) => HourlyForecast.fromJson(e)).toList() ?? [];
    final daily = (json['daily'] as List?)?.map((e) => DailyForecast.fromJson(e)).toList() ?? [];
    return ForecastModel(hourly: hourly, daily: daily);
  }
} 