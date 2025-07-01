import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _apiKey = '831a2d754fa7498dad92e354c8b49964'; // Clé API utilisateur
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  
  // Villes par défaut pour l'application
  static const List<Map<String, dynamic>> _defaultCities = [
    {'name': 'Paris', 'lat': 48.8566, 'lon': 2.3522},
    {'name': 'New York', 'lat': 40.7128, 'lon': -74.0060},
    {'name': 'Tokyo', 'lat': 35.6762, 'lon': 139.6503},
    {'name': 'London', 'lat': 51.5074, 'lon': -0.1278},
    {'name': 'Sydney', 'lat': -33.8688, 'lon': 151.2093},
  ];

  // Méthode pour obtenir la météo d'une ville par coordonnées
  Future<WeatherModel> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=fr'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Erreur lors de la récupération des données météo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Méthode pour obtenir la météo d'une ville par nom
  Future<WeatherModel> getWeatherByCityName(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?q=$cityName&appid=$_apiKey&units=metric&lang=fr'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Erreur lors de la récupération des données météo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Méthode pour obtenir la météo actuelle (alias pour getWeatherByCityName)
  Future<WeatherModel?> getCurrentWeather(String cityName) async {
    try {
      return await getWeatherByCityName(cityName);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la météo: $e');
    }
  }

  // Méthode pour obtenir la météo de toutes les villes par défaut
  Future<List<WeatherModel>> getAllDefaultCitiesWeather() async {
    List<WeatherModel> weatherList = [];
    
    for (var city in _defaultCities) {
      try {
        final weather = await getWeatherByCoordinates(city['lat'], city['lon']);
        weatherList.add(weather);
      } catch (e) {
        // Ignorer les erreurs pour les villes individuelles
        continue;
      }
    }
    
    return weatherList;
  }

  // Méthode pour obtenir la météo de la localisation actuelle
  Future<WeatherModel> getCurrentLocationWeather(double lat, double lon) async {
    return await getWeatherByCoordinates(lat, lon);
  }

  // Méthode pour obtenir l'URL de l'icône météo
  static String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  // Méthode pour obtenir l'URL de l'icône météo en taille normale
  static String getWeatherIconUrlSmall(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode.png';
  }
} 