import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:video_compress/video_compress.dart';
import '../models/social_post.dart';
import '../models/weather_challenge.dart';
import '../models/weather_achievement.dart';
import '../models/weather_comparison.dart';
import '../models/custom_alert.dart';
import 'haptic_service.dart';
import 'audio_service.dart';
import 'weather_service.dart';

class SocialWeatherService {
  static final SocialWeatherService _instance = SocialWeatherService._internal();
  factory SocialWeatherService() => _instance;
  SocialWeatherService._internal();

  final List<SocialPost> _posts = [];
  final List<WeatherChallenge> _challenges = [];
  final List<WeatherAchievement> _achievements = [];
  final HapticService _hapticService = HapticService();
  final AudioService _audioService = AudioService();
  final WeatherService _weatherService = WeatherService();

  // Weather challenge types
  static const List<String> _challengeTypes = [
    'sunny_week',
    'rainy_week',
    'temperature_extreme',
    'weather_photo',
    'forecast_accuracy',
  ];

  // Achievement types
  static const List<String> _achievementTypes = [
    'first_post',
    'weekly_streak',
    'photo_master',
    'forecast_expert',
    'social_butterfly',
  ];

  // Predefined social post templates
  static final List<SocialPostTemplate> _templates = [
    SocialPostTemplate(
      id: 'sunny_day',
      title: 'Journée ensoleillée',
      template: '☀️ Belle journée ensoleillée à {city} ! {temperature}°C',
      variables: ['city', 'temperature'],
      type: SocialPostType.weatherUpdate,
      icon: '☀️',
    ),
    SocialPostTemplate(
      id: 'rainy_day',
      title: 'Journée pluvieuse',
      template: '🌧️ Pluie à {city} aujourd\'hui. {temperature}°C',
      variables: ['city', 'temperature'],
      type: SocialPostType.weatherUpdate,
      icon: '🌧️',
    ),
    SocialPostTemplate(
      id: 'snow_day',
      title: 'Journée neigeuse',
      template: '❄️ Neige à {city} ! {temperature}°C',
      variables: ['city', 'temperature'],
      type: SocialPostType.weatherUpdate,
      icon: '❄️',
    ),
  ];

  // Initialisation
  Future<void> initialize() async {
    await _loadLocalData();
    await _loadChallengesLocally();
    await _loadAchievementsLocally();
  }

  // Charger les données locales
  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getStringList('local_posts') ?? [];
    final posts = postsJson
        .map((json) => SocialPost.fromJson(jsonDecode(json)))
        .toList();
    _posts.clear();
    _posts.addAll(posts);
  }

  // Sauvegarder les données locales
  Future<void> _saveLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = _posts
        .map((post) => jsonEncode(post.toJson()))
        .toList();
    await prefs.setStringList('local_posts', postsJson);
  }

  // Charger les défis localement
  Future<void> _loadChallengesLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final challengesJson = prefs.getStringList('local_challenges') ?? [];
    final challenges = challengesJson
        .map((json) => WeatherChallenge.fromJson(jsonDecode(json)))
        .toList();
    _challenges.clear();
    _challenges.addAll(challenges);
  }

  // Charger les achievements localement
  Future<void> _loadAchievementsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getStringList('local_achievements') ?? [];
    final achievements = achievementsJson
        .map((json) => WeatherAchievement.fromJson(jsonDecode(json)))
        .toList();
    _achievements.clear();
    _achievements.addAll(achievements);
  }

  // Créer un nouveau post
  Future<SocialPost?> createPost({
    required String message,
    required String location,
    String? imagePath,
    String? videoPath,
    SocialPostType type = SocialPostType.weatherUpdate,
  }) async {
    try {
      // Obtenir les données météo actuelles
      final weatherData = await _weatherService.getCurrentWeather(location);
      if (weatherData == null) return null;

      final post = SocialPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        userName: 'Utilisateur Météo',
        userAvatar: 'https://via.placeholder.com/150',
        weatherData: weatherData,
        message: message,
        location: location,
        timestamp: DateTime.now(),
        hashtags: _extractHashtags(message),
        imageUrl: imagePath,
        videoUrl: videoPath,
        type: type,
      );

      _posts.insert(0, post);
      await _saveLocalData();

      _hapticService.triggerSuccess();
      _audioService.playSuccessSound();

      // Vérifier les achievements
      await _checkAchievements(post);

      return post;
    } catch (e) {
      throw Exception('Erreur lors de la création du post: $e');
    }
  }

  // Extraire les hashtags du message
  List<String> _extractHashtags(String message) {
    final regex = RegExp(r'#\w+');
    return regex.allMatches(message).map((match) => match.group(0)!).toList();
  }

  // Partager sur les réseaux sociaux
  Future<bool> shareToSocialMedia(SocialPost post, String platform) async {
    try {
      // Ici, vous intégreriez l'API de partage spécifique à la plateforme
      
      _hapticService.triggerSuccess();
      return true;
    } catch (e) {
      _hapticService.triggerError();
      return false;
    }
  }

  // Obtenir tous les posts
  List<SocialPost> getAllPosts() {
    return List.from(_posts);
  }

  // Obtenir les posts par type
  List<SocialPost> getPostsByType(SocialPostType type) {
    return _posts.where((post) => post.type == type).toList();
  }

  // Liker un post
  Future<void> likePost(String postId) async {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final updatedPost = post.copyWith(
        likes: post.likes + 1,
        likedBy: [...post.likedBy, 'current_user'],
      );
      _posts[postIndex] = updatedPost;
      await _saveLocalData();
      _hapticService.triggerSuccess();
    }
  }

  // Créer un défi météo
  Future<WeatherChallenge?> createWeatherChallenge({
    required String title,
    required String description,
    required ChallengeType type,
    required DateTime endDate,
    String? reward,
  }) async {
    try {
      final challenge = WeatherChallenge(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        type: type,
        startDate: DateTime.now(),
        endDate: endDate,
        reward: reward,
        participants: [],
        submissions: [],
      );

      _challenges.add(challenge);
      await _saveChallengesLocally();

      _hapticService.triggerSuccess();
      _audioService.playSuccessSound();

      return challenge;
    } catch (e) {
      _hapticService.triggerError();
      return null;
    }
  }

  // Participer à un défi
  Future<bool> participateInChallenge(String challengeId) async {
    try {
      final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
      if (challengeIndex != -1) {
        final challenge = _challenges[challengeIndex];
        if (!challenge.participants.contains('current_user')) {
          final updatedChallenge = challenge.copyWith(
            participants: [...challenge.participants, 'current_user'],
          );
          _challenges[challengeIndex] = updatedChallenge;
          await _saveChallengesLocally();
          _hapticService.triggerSuccess();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Soumettre une participation à un défi
  Future<bool> submitChallengeEntry(String challengeId, String submission) async {
    try {
      final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
      if (challengeIndex != -1) {
        final challenge = _challenges[challengeIndex];
        final entry = ChallengeSubmission(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'current_user',
          userName: 'Utilisateur Météo',
          submission: submission,
          timestamp: DateTime.now(),
          likes: 0,
        );

        final updatedChallenge = challenge.copyWith(
          submissions: [...challenge.submissions, entry],
        );
        _challenges[challengeIndex] = updatedChallenge;
        await _saveChallengesLocally();

        _hapticService.triggerSuccess();
        _audioService.playAchievementSound();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Obtenir tous les défis
  List<WeatherChallenge> getAllChallenges() {
    return List.from(_challenges);
  }

  // Obtenir les défis actifs
  List<WeatherChallenge> getActiveChallenges() {
    final now = DateTime.now();
    return _challenges.where((challenge) => challenge.endDate.isAfter(now)).toList();
  }

  // Comparer la météo entre deux villes
  Future<WeatherComparison?> compareWeather(String city1, String city2) async {
    try {
      final weather1 = await _weatherService.getCurrentWeather(city1);
      final weather2 = await _weatherService.getCurrentWeather(city2);
      
      if (weather1 == null || weather2 == null) return null;

      return WeatherComparison(
        city1: city1,
        city2: city2,
        weather1: weather1,
        weather2: weather2,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  // Créer une alerte météo personnalisée
  Future<CustomAlert?> createCustomAlert({
    required String title,
    required String condition,
    required String location,
    required double threshold,
    required AlertType type,
  }) async {
    try {
      final alert = CustomAlert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        condition: condition,
        location: location,
        threshold: threshold,
        type: type,
        isActive: true,
        createdAt: DateTime.now(),
      );

      // Sauvegarder l'alerte
      final prefs = await SharedPreferences.getInstance();
      final alerts = prefs.getStringList('custom_alerts') ?? [];
      alerts.add(jsonEncode(alert.toJson()));
      await prefs.setStringList('custom_alerts', alerts);

      _hapticService.triggerLight();
      return alert;
    } catch (e) {
      return null;
    }
  }

  // Obtenir les alertes personnalisées
  Future<List<CustomAlert>> getCustomAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = prefs.getStringList('custom_alerts') ?? [];
      return alertsJson
          .map((json) => CustomAlert.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Vérifier les achievements
  Future<void> _checkAchievements(SocialPost post) async {
    // Premier post
    if (_posts.length == 1) {
      await _unlockAchievement('first_post');
    }

    // Streak hebdomadaire
    final weekAgo = DateTime.now().subtract(Duration(days: 7));
    final weeklyPosts = _posts.where((p) => p.timestamp.isAfter(weekAgo)).length;
    if (weeklyPosts >= 7) {
      await _unlockAchievement('weekly_streak');
    }

    // Post avec photo
    if (post.imageUrl != null) {
      await _unlockAchievement('photo_master');
    }
  }

  // Débloquer un achievement
  Future<void> _unlockAchievement(String achievementType) async {
    if (_achievements.any((a) => a.type == achievementType)) return;

    final achievement = WeatherAchievement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: achievementType,
      title: _getAchievementTitle(achievementType),
      description: _getAchievementDescription(achievementType),
      unlockedAt: DateTime.now(),
      icon: _getAchievementIcon(achievementType),
    );

    _achievements.add(achievement);
    await _saveAchievementsLocally();

    _hapticService.triggerSuccess();
    _audioService.playAchievementSound();
  }

  // Sauvegarder les défis
  Future<void> _saveChallengesLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final challengesJson = _challenges
        .map((challenge) => jsonEncode(challenge.toJson()))
        .toList();
    await prefs.setStringList('local_challenges', challengesJson);
  }

  // Sauvegarder les achievements
  Future<void> _saveAchievementsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = _achievements
        .map((achievement) => jsonEncode(achievement.toJson()))
        .toList();
    await prefs.setStringList('local_achievements', achievementsJson);
  }

  // Obtenir le titre d'un achievement
  String _getAchievementTitle(String type) {
    switch (type) {
      case 'first_post':
        return 'Premier Post';
      case 'weekly_streak':
        return 'Streak Hebdomadaire';
      case 'photo_master':
        return 'Maître Photo';
      case 'forecast_expert':
        return 'Expert Prévisions';
      case 'social_butterfly':
        return 'Papillon Social';
      default:
        return 'Achievement';
    }
  }

  // Obtenir la description d'un achievement
  String _getAchievementDescription(String type) {
    switch (type) {
      case 'first_post':
        return 'Vous avez créé votre premier post météo !';
      case 'weekly_streak':
        return 'Vous avez posté pendant 7 jours consécutifs !';
      case 'photo_master':
        return 'Vous avez partagé une photo météo !';
      case 'forecast_expert':
        return 'Vos prévisions sont très précises !';
      case 'social_butterfly':
        return 'Vous êtes très actif sur le réseau !';
      default:
        return 'Achievement débloqué !';
    }
  }

  // Obtenir l'icône d'un achievement
  String _getAchievementIcon(String type) {
    switch (type) {
      case 'first_post':
        return '🎉';
      case 'weekly_streak':
        return '🔥';
      case 'photo_master':
        return '📸';
      case 'forecast_expert':
        return '🔮';
      case 'social_butterfly':
        return '🦋';
      default:
        return '🏆';
    }
  }

  // Compresser une image
  Future<String?> compressImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;

      // Redimensionner l'image
      final resized = img.copyResize(image, width: 800);
      final compressed = img.encodeJpg(resized, quality: 85);
      
      final tempDir = await getTemporaryDirectory();
      final compressedPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await File(compressedPath).writeAsBytes(compressed);
      return compressedPath;
    } catch (e) {
      return null;
    }
  }

  // Compresser une vidéo
  Future<String?> compressVideo(String videoPath) async {
    try {
      final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        videoPath,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
      );
      
      return mediaInfo?.file?.path;
    } catch (e) {
      return null;
    }
  }

  // Obtenir les templates
  List<SocialPostTemplate> getTemplates() {
    return List.from(_templates);
  }

  // Obtenir les types de défis
  List<String> getChallengeTypes() {
    return List.from(_challengeTypes);
  }

  // Obtenir les types d'achievements
  List<String> getAchievementTypes() {
    return List.from(_achievementTypes);
  }

  // Obtenir les achievements
  List<WeatherAchievement> getAchievements() {
    return List.from(_achievements);
  }

  // Rejoindre un défi météo
  Future<bool> joinWeatherChallenge(String challengeId) async {
    try {
      final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
      if (challengeIndex != -1) {
        final challenge = _challenges[challengeIndex];
        if (!challenge.participants.contains('current_user')) {
          final updatedChallenge = challenge.copyWith(
            participants: [...challenge.participants, 'current_user'],
          );
          _challenges[challengeIndex] = updatedChallenge;
          await _saveChallengesLocally();
          _hapticService.triggerSuccess();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Liker/déliker un post
  Future<void> togglePostLike(String postId) async {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final isLiked = post.likedBy.contains('current_user');
      final updatedPost = post.copyWith(
        likes: isLiked ? post.likes - 1 : post.likes + 1,
        likedBy: isLiked
            ? (post.likedBy..remove('current_user'))
            : (post.likedBy..add('current_user')),
      );
      _posts[postIndex] = updatedPost;
      await _saveLocalData();
      _hapticService.triggerSuccess();
    }
  }

  // Comparer la météo entre deux villes
  Future<WeatherComparison?> getWeatherComparison(String city1, String city2) async {
    try {
      final weather1 = await _weatherService.getCurrentWeather(city1);
      final weather2 = await _weatherService.getCurrentWeather(city2);
      if (weather1 == null || weather2 == null) return null;
      return WeatherComparison(
        city1: city1,
        city2: city2,
        weather1: weather1,
        weather2: weather2,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> addPost(SocialPost post) async {
    _posts.add(post);
    _hapticService.triggerSuccess();
    _audioService.playSuccessSound();
  }

  Future<void> addChallenge(WeatherChallenge challenge) async {
    _challenges.add(challenge);
    _hapticService.triggerSuccess();
    _audioService.playSuccessSound();
  }

  Future<void> addAchievement(WeatherAchievement achievement) async {
    _achievements.add(achievement);
    _hapticService.triggerSuccess();
    _audioService.playSuccessSound();
  }
} 