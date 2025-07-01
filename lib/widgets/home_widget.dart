import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../models/weather_model.dart';

class HomeWidgetService {
  static const String _temperatureKey = 'temperature';
  static const String _cityKey = 'city';
  static const String _conditionKey = 'condition';

  static Future<void> updateWidget(WeatherModel weather) async {
    try {
      await HomeWidget.saveWidgetData(_temperatureKey, weather.temperature.round());
      await HomeWidget.saveWidgetData(_cityKey, weather.city);
      await HomeWidget.saveWidgetData(_conditionKey, weather.description);
      await HomeWidget.saveWidgetData('icon', weather.icon);
      await HomeWidget.updateWidget(
        androidName: 'WeatherWidgetProvider',
        iOSName: 'WeatherWidget',
      );
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  static Future<void> initializeWidget() async {
    try {
      await HomeWidget.setAppGroupId('group.com.example.app_meteo');
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }
}

class WeatherWidgetPreview extends StatelessWidget {
  final WeatherModel weather;

  const WeatherWidgetPreview({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF03DAC6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icône météo
            Image.network(
              'https://openweathermap.org/img/wn/${weather.icon}.png',
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.wb_sunny_rounded,
                  color: Colors.white,
                  size: 40,
                );
              },
            ),
            const SizedBox(width: 8),
            // Informations météo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weather.city,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${weather.temperature.round()}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    weather.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 