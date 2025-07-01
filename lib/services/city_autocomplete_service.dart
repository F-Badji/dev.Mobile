import 'dart:convert';
import 'package:http/http.dart' as http;

class CitySuggestion {
  final String name;
  final String country;
  final double lat;
  final double lon;

  CitySuggestion({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory CitySuggestion.fromJson(Map<String, dynamic> json) {
    return CitySuggestion(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lon: (json['lon'] ?? 0.0).toDouble(),
    );
  }
}

class CityAutocompleteService {
  static const String _apiKey = '831a2d754fa7498dad92e354c8b49964';
  static const String _baseUrl = 'https://api.openweathermap.org/geo/1.0/direct';

  Future<List<CitySuggestion>> getSuggestions(String query) async {
    if (query.isEmpty) return [];
    final url = '$_baseUrl?q=$query&limit=5&appid=$_apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => CitySuggestion.fromJson(e)).toList();
    } else {
      return [];
    }
  }
} 