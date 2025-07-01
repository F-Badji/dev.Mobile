import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AccessibilityService extends ChangeNotifier {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  final FlutterTts _tts = FlutterTts();

  bool _largeText = false;
  bool _highContrast = false;
  bool _screenReader = false;
  double _textScaleFactor = 1.0;

  bool get largeText => _largeText;
  bool get highContrast => _highContrast;
  bool get screenReader => _screenReader;
  double get textScaleFactor => _textScaleFactor;

  void toggleLargeText() {
    _largeText = !_largeText;
    _textScaleFactor = _largeText ? 1.3 : 1.0;
    notifyListeners();
  }

  void toggleHighContrast() {
    _highContrast = !_highContrast;
    notifyListeners();
  }

  void toggleScreenReader() {
    _screenReader = !_screenReader;
    if (_screenReader) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    }
    notifyListeners();
  }

  Future<void> speak(String text) async {
    if (_screenReader) {
      await _tts.setLanguage('fr-FR');
      await _tts.setSpeechRate(0.5);
      await _tts.speak(text);
    }
  }

  ThemeData getAccessibleTheme(ThemeData baseTheme) {
    if (_highContrast) {
      return baseTheme.copyWith(
        brightness: Brightness.dark,
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: Colors.white,
          secondary: Colors.yellow,
          surface: Colors.grey[900],
          onSurface: Colors.white,
        ),
      );
    }
    return baseTheme;
  }
} 