class WeatherChallenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final DateTime startDate;
  final DateTime endDate;
  final String? reward;
  final List<String> participants;
  final List<ChallengeSubmission> submissions;

  WeatherChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.reward,
    this.participants = const [],
    this.submissions = const [],
  });

  factory WeatherChallenge.fromJson(Map<String, dynamic> json) {
    return WeatherChallenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ChallengeTypeExtension.fromString(json['type']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      reward: json['reward'],
      participants: List<String>.from(json['participants'] ?? []),
      submissions: (json['submissions'] as List<dynamic>? ?? [])
          .map((e) => ChallengeSubmission.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reward': reward,
      'participants': participants,
      'submissions': submissions.map((e) => e.toJson()).toList(),
    };
  }

  WeatherChallenge copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? reward,
    List<String>? participants,
    List<ChallengeSubmission>? submissions,
  }) {
    return WeatherChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reward: reward ?? this.reward,
      participants: participants ?? this.participants,
      submissions: submissions ?? this.submissions,
    );
  }
}

enum ChallengeType {
  temperaturePrediction,
  weatherPhoto,
  locationExploration,
  weatherStreak,
}

extension ChallengeTypeExtension on ChallengeType {
  static ChallengeType fromString(String value) {
    switch (value) {
      case 'temperaturePrediction':
        return ChallengeType.temperaturePrediction;
      case 'weatherPhoto':
        return ChallengeType.weatherPhoto;
      case 'locationExploration':
        return ChallengeType.locationExploration;
      case 'weatherStreak':
        return ChallengeType.weatherStreak;
      default:
        return ChallengeType.weatherPhoto;
    }
  }

  String get name {
    switch (this) {
      case ChallengeType.temperaturePrediction:
        return 'temperaturePrediction';
      case ChallengeType.weatherPhoto:
        return 'weatherPhoto';
      case ChallengeType.locationExploration:
        return 'locationExploration';
      case ChallengeType.weatherStreak:
        return 'weatherStreak';
    }
  }
}

class ChallengeSubmission {
  final String id;
  final String userId;
  final String userName;
  final String submission;
  final DateTime timestamp;
  final int likes;

  ChallengeSubmission({
    required this.id,
    required this.userId,
    required this.userName,
    required this.submission,
    required this.timestamp,
    this.likes = 0,
  });

  factory ChallengeSubmission.fromJson(Map<String, dynamic> json) {
    return ChallengeSubmission(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      submission: json['submission'],
      timestamp: DateTime.parse(json['timestamp']),
      likes: json['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'submission': submission,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
    };
  }
} 