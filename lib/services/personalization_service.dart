import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalizationService extends ChangeNotifier {
  static final PersonalizationService _instance = PersonalizationService._internal();
  factory PersonalizationService() => _instance;
  PersonalizationService._internal();

  bool _isDarkMode = false;
  bool _animationsEnabled = true;
  bool _soundsEnabled = true;
  bool _hapticsEnabled = true;
  String _selectedTheme = 'default';
  double _animationSpeed = 1.0;

  bool get isDarkMode => _isDarkMode;
  bool get animationsEnabled => _animationsEnabled;
  bool get soundsEnabled => _soundsEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  String get selectedTheme => _selectedTheme;
  double get animationSpeed => _animationSpeed;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    _animationsEnabled = prefs.getBool('animations_enabled') ?? true;
    _soundsEnabled = prefs.getBool('sounds_enabled') ?? true;
    _hapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
    _selectedTheme = prefs.getString('selected_theme') ?? 'default';
    _animationSpeed = prefs.getDouble('animation_speed') ?? 1.0;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> toggleAnimations() async {
    _animationsEnabled = !_animationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('animations_enabled', _animationsEnabled);
    notifyListeners();
  }

  Future<void> toggleSounds() async {
    _soundsEnabled = !_soundsEnabled;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('sounds_enabled', _soundsEnabled);
    notifyListeners();
  }

  Future<void> toggleHaptics() async {
    _hapticsEnabled = !_hapticsEnabled;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('haptics_enabled', _hapticsEnabled);
    notifyListeners();
  }

  Future<void> setTheme(String theme) async {
    _selectedTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selected_theme', theme);
    notifyListeners();
  }

  Future<void> setAnimationSpeed(double speed) async {
    _animationSpeed = speed;
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('animation_speed', speed);
    notifyListeners();
  }
} 