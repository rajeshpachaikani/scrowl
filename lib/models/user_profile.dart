class UserProfile {
  final String id;
  final String username;
  final String? email;
  final List<String> interests;
  final int rewardPoints;
  final int rank;
  final List<String> likedTriviaIds;
  final List<String> savedTriviaIds;
  final DateTime createdAt;
  final DateTime lastActive;

  UserProfile({
    required this.id,
    required this.username,
    this.email,
    required this.interests,
    this.rewardPoints = 0,
    this.rank = 0,
    this.likedTriviaIds = const [],
    this.savedTriviaIds = const [],
    required this.createdAt,
    required this.lastActive,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      interests: List<String>.from(json['interests'] ?? []),
      rewardPoints: json['rewardPoints'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      likedTriviaIds: List<String>.from(json['likedTriviaIds'] ?? []),
      savedTriviaIds: List<String>.from(json['savedTriviaIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActive: DateTime.parse(json['lastActive'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'interests': interests,
      'rewardPoints': rewardPoints,
      'rank': rank,
      'likedTriviaIds': likedTriviaIds,
      'savedTriviaIds': savedTriviaIds,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? username,
    String? email,
    List<String>? interests,
    int? rewardPoints,
    int? rank,
    List<String>? likedTriviaIds,
    List<String>? savedTriviaIds,
    DateTime? lastActive,
  }) {
    return UserProfile(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      interests: interests ?? this.interests,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      rank: rank ?? this.rank,
      likedTriviaIds: likedTriviaIds ?? this.likedTriviaIds,
      savedTriviaIds: savedTriviaIds ?? this.savedTriviaIds,
      createdAt: createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
