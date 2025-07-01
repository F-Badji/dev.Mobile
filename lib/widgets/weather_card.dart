import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../utils/constants.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final VoidCallback? onTap;

  const WeatherCard({
    super.key,
    required this.weather,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(38),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: Colors.white.withAlpha(51),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône météo
            Image.network(
              WeatherService.getWeatherIconUrl(weather.icon),
              width: 60,
              height: 60,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.wb_sunny_rounded,
                  size: 60,
                  color: Colors.white,
                );
              },
            ),
            const SizedBox(width: AppConstants.paddingLarge),
            // Infos principales
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.city,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            // Température
            Text(
              '${weather.temperature.round()}°C',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
} 