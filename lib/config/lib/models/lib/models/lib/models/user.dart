class AppUser {
  final String uid;
  final String email;
  final String username;
  final String? photoUrl;
  final int totalPoints;
  final int availablePoints;
  final int totalBets;
  final int wonBets;
  final double winRate;
  final DateTime createdAt;
  final String country;
  final bool isPremium;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    this.photoUrl,
    required this.totalPoints,
    required this.availablePoints,
    required this.totalBets,
    required this.wonBets,
    required this.winRate,
    required this.createdAt,
    required this.country,
    required this.isPremium,
  });

  String getRank() {
    if (totalPoints >= 10000) return '🥇 Legend';
    if (totalPoints >= 5000) return '💎 Master';
    if (totalPoints >= 1000) return '🏆 Expert';
    if (totalPoints >= 100) return '⭐ Pro';
    return '🌟 Novice';
  }

  double getROI() {
    if (totalBets == 0) return 0;
    int totalStaked = (totalPoints * 0.1).toInt();
    return ((totalPoints - totalStaked) / totalStaked * 100);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'photoUrl': photoUrl,
      'totalPoints': totalPoints,
      'availablePoints': availablePoints,
      'totalBets': totalBets,
      'wonBets': wonBets,
      'winRate': winRate,
      'createdAt': createdAt.toIso8601String(),
      'country': country,
      'isPremium': isPremium,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? 'User',
      photoUrl: map['photoUrl'],
      totalPoints: map['totalPoints'] ?? 1000,
      availablePoints: map['availablePoints'] ?? 1000,
      totalBets: map['totalBets'] ?? 0,
      wonBets: map['wonBets'] ?? 0,
      winRate: (map['winRate'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      country: map['country'] ?? 'FR',
      isPremium: map['isPremium'] ?? false,
    );
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? username,
    String? photoUrl,
    int? totalPoints,
    int? availablePoints,
    int? totalBets,
    int? wonBets,
    double? winRate,
    DateTime? createdAt,
    String? country,
    bool? isPremium,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      availablePoints: availablePoints ?? this.availablePoints,
      totalBets: totalBets ?? this.totalBets,
      wonBets: wonBets ?? this.wonBets,
      winRate: winRate ?? this.winRate,
      createdAt: createdAt ?? this.createdAt,
      country: country ?? this.country,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
