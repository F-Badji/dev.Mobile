import 'weather_model.dart';

class SocialPost {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final WeatherModel weatherData;
  final String message;
  final String location;
  final DateTime timestamp;
  final List<String> hashtags;
  final int likes;
  final int shares;
  final List<String> likedBy;
  final String? imageUrl;
  final String? videoUrl;
  final SocialPostType type;
  final Map<String, dynamic> metadata;

  SocialPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.weatherData,
    required this.message,
    required this.location,
    required this.timestamp,
    required this.hashtags,
    this.likes = 0,
    this.shares = 0,
    this.likedBy = const [],
    this.imageUrl,
    this.videoUrl,
    this.type = SocialPostType.weatherUpdate,
    this.metadata = const {},
  });

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      weatherData: WeatherModel.fromJson(json['weatherData']),
      message: json['message'],
      location: json['location'],
      timestamp: DateTime.parse(json['timestamp']),
      hashtags: List<String>.from(json['hashtags']),
      likes: json['likes'] ?? 0,
      shares: json['shares'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      type: SocialPostType.values.firstWhere(
        (e) => e.toString() == 'SocialPostType.${json['type']}',
        orElse: () => SocialPostType.weatherUpdate,
      ),
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'weatherData': weatherData.toJson(),
      'message': message,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'hashtags': hashtags,
      'likes': likes,
      'shares': shares,
      'likedBy': likedBy,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'type': type.toString().split('.').last,
      'metadata': metadata,
    };
  }

  SocialPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    WeatherModel? weatherData,
    String? message,
    String? location,
    DateTime? timestamp,
    List<String>? hashtags,
    int? likes,
    int? shares,
    List<String>? likedBy,
    String? imageUrl,
    String? videoUrl,
    SocialPostType? type,
    Map<String, dynamic>? metadata,
  }) {
    return SocialPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      weatherData: weatherData ?? this.weatherData,
      message: message ?? this.message,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      hashtags: hashtags ?? this.hashtags,
      likes: likes ?? this.likes,
      shares: shares ?? this.shares,
      likedBy: likedBy ?? this.likedBy,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String get weatherEmoji {
    final condition = weatherData.description.toLowerCase();
    if (condition.contains('sunny') || condition.contains('clear')) {
      return '☀️';
    } else if (condition.contains('cloudy') || condition.contains('overcast')) {
      return '☁️';
    } else if (condition.contains('rain')) {
      return '🌧️';
    } else if (condition.contains('snow')) {
      return '❄️';
    } else if (condition.contains('storm')) {
      return '⛈️';
    } else if (condition.contains('fog') || condition.contains('mist')) {
      return '🌫️';
    } else {
      return '🌤️';
    }
  }

  String get formattedMessage {
    return '$weatherEmoji $message';
  }
}

enum SocialPostType {
  weatherUpdate,
  weatherAlert,
  weatherComparison,
  weatherChallenge,
  weatherAchievement,
  weatherPhoto,
  weatherVideo,
  weatherStory,
}

class SocialPostTemplate {
  final String id;
  final String title;
  final String template;
  final List<String> variables;
  final SocialPostType type;
  final String? icon;
  final Map<String, dynamic> metadata;

  SocialPostTemplate({
    required this.id,
    required this.title,
    required this.template,
    required this.variables,
    required this.type,
    this.icon,
    this.metadata = const {},
  });

  String generateMessage(Map<String, String> values) {
    String message = template;
    for (String variable in variables) {
      if (values.containsKey(variable)) {
        message = message.replaceAll('{$variable}', values[variable]!);
      }
    }
    return message;
  }

  factory SocialPostTemplate.fromJson(Map<String, dynamic> json) {
    return SocialPostTemplate(
      id: json['id'],
      title: json['title'],
      template: json['template'],
      variables: List<String>.from(json['variables']),
      type: SocialPostType.values.firstWhere(
        (e) => e.toString() == 'SocialPostType.${json['type']}',
        orElse: () => SocialPostType.weatherUpdate,
      ),
      icon: json['icon'],
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'template': template,
      'variables': variables,
      'type': type.toString().split('.').last,
      'icon': icon,
      'metadata': metadata,
    };
  }
} 