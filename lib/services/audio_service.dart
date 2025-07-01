import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;

  // Sons météo
  static const Map<String, String> _weatherSounds = {
    'rain': 'assets/sounds/rain.mp3',
    'thunder': 'assets/sounds/thunder.mp3',
    'wind': 'assets/sounds/wind.mp3',
    'sunny': 'assets/sounds/sunny.mp3',
    'snow': 'assets/sounds/snow.mp3',
    'success': 'assets/sounds/success.mp3',
    'error': 'assets/sounds/error.mp3',
  };

  Future<void> playWeatherSound(String weatherType) async {
    try {
      final audioPlayer = AudioPlayer();
      final soundPath = _getWeatherSoundPath(weatherType);
      
      // Vérifier si le fichier existe avant de le jouer
      if (soundPath != null) {
        await audioPlayer.play(AssetSource(soundPath));
      }
    } catch (e) {
      // Ignorer les erreurs d'audio manquant
      print('Audio file not found: $e');
    }
  }

  void playSuccessSound() {
    if (_isMuted) return;
    _audioPlayer.play(AssetSource(_weatherSounds['success']!));
  }

  void playErrorSound() {
    if (_isMuted) return;
    _audioPlayer.play(AssetSource(_weatherSounds['error']!));
  }

  void playAchievementSound() {
    if (_isMuted) return;
    _audioPlayer.play(AssetSource(_weatherSounds['success']!));
  }

  void stopSound() {
    _audioPlayer.stop();
  }

  void setVolume(double volume) {
    _audioPlayer.setVolume(volume);
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _audioPlayer.stop();
    }
  }

  bool get isMuted => _isMuted;

  String? _getWeatherSoundPath(String weatherType) {
    switch (weatherType.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return 'sounds/sunny.mp3';
      case 'rain':
      case 'drizzle':
        return 'sounds/rain.mp3';
      case 'snow':
        return 'sounds/snow.mp3';
      case 'cloudy':
      case 'overcast':
        return 'sounds/cloudy.mp3';
      case 'thunderstorm':
        return 'sounds/thunder.mp3';
      default:
        return null; // Retourner null si aucun son n'est disponible
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
} 