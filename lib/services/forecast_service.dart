import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/forecast_model.dart';

class ForecastService {
  static const String _apiKey = '831a2d754fa7498dad92e354c8b49964';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/onecall';

  Future<ForecastModel> getForecast(double lat, double lon) async {
    final url = '$_baseUrl?lat=$lat&lon=$lon&exclude=minutely,current,alerts&units=metric&lang=fr&appid=$_apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ForecastModel.fromJson(data);
    } else {
      throw Exception('Erreur lors de la récupération des prévisions météo');
    }
  }
} 