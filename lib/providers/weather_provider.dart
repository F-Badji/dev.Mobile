import 'dart:async';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  
  // États de l'application
  bool _isLoading = false;
  bool _isProgressComplete = false;
  double _progress = 0.0;
  String _loadingMessage = '';
  List<WeatherModel> _weatherData = [];
  String? _errorMessage;
  bool _isDarkMode = false;
  
  // Messages de chargement
  final List<String> _loadingMessages = [
    'Nous téléchargeons les données...',
    'C\'est presque fini...',
    'Plus que quelques secondes avant d\'avoir le résultat...',
    'Préparation des données météo...',
    'Analyse des conditions atmosphériques...',
  ];
  
  int _currentMessageIndex = 0;
  Timer? _messageTimer;
  Timer? _progressTimer;

  // Getters
  bool get isLoading => _isLoading;
  bool get isProgressComplete => _isProgressComplete;
  double get progress => _progress;
  String get loadingMessage => _loadingMessage;
  List<WeatherModel> get weatherData => _weatherData;
  String? get errorMessage => _errorMessage;
  bool get isDarkMode => _isDarkMode;

  WeatherProvider() {
    _loadingMessage = _loadingMessages[0];
  }

  // Méthode pour démarrer l'expérience météo
  Future<void> startWeatherExperience() async {
    _resetState();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Démarrer les timers pour l'animation
    _startMessageRotation();
    _startProgressAnimation();

    try {
      // Récupérer les données météo
      final weatherList = await _weatherService.getAllDefaultCitiesWeather();
      
      // Attendre que la barre de progression soit complète
      while (_progress < 1.0) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      _weatherData = weatherList;
      _isProgressComplete = true;
      _isLoading = false;
      
      // Arrêter les timers
      _stopTimers();
      
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _stopTimers();
      notifyListeners();
    }
  }

  // Méthode pour recommencer l'expérience
  Future<void> restartExperience() async {
    _resetState();
    await startWeatherExperience();
  }

  // Méthode pour réinitialiser l'état
  void _resetState() {
    _isLoading = false;
    _isProgressComplete = false;
    _progress = 0.0;
    _weatherData = [];
    _errorMessage = null;
    _currentMessageIndex = 0;
    _loadingMessage = _loadingMessages[0];
    _stopTimers();
  }

  // Méthode pour démarrer la rotation des messages
  void _startMessageRotation() {
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _currentMessageIndex = (_currentMessageIndex + 1) % _loadingMessages.length;
      _loadingMessage = _loadingMessages[_currentMessageIndex];
      notifyListeners();
    });
  }

  // Méthode pour démarrer l'animation de progression
  void _startProgressAnimation() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_progress < 1.0) {
        _progress += 0.01;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  // Méthode pour arrêter les timers
  void _stopTimers() {
    _messageTimer?.cancel();
    _progressTimer?.cancel();
  }

  // Méthode pour basculer le mode sombre/clair
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Méthode pour effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Méthode pour obtenir la météo d'une ville spécifique
  Future<WeatherModel?> getWeatherForCity(String cityName) async {
    try {
      return await _weatherService.getWeatherByCityName(cityName);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Méthode pour obtenir la météo de la localisation actuelle
  Future<WeatherModel?> getCurrentLocationWeather(double lat, double lon) async {
    try {
      return await _weatherService.getCurrentLocationWeather(lat, lon);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }
} 