class LoyaltyCard {
  final String id;
  final String userId;
  final int pointsBalance;
  final int totalPointsEarned;
  final int totalPointsRedeemed;
  final String tierLevel; // bronze, silver, gold, platinum
  final DateTime createdAt;
  final DateTime? lastUpdated;

  LoyaltyCard({
    required this.id,
    required this.userId,
    required this.pointsBalance,
    required this.totalPointsEarned,
    required this.totalPointsRedeemed,
    required this.tierLevel,
    required this.createdAt,
    this.lastUpdated,
  });

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      pointsBalance: json['points_balance'] as int,
      totalPointsEarned: json['total_points_earned'] as int,
      totalPointsRedeemed: json['total_points_redeemed'] as int,
      tierLevel: json['tier_level'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'points_balance': pointsBalance,
      'total_points_earned': totalPointsEarned,
      'total_points_redeemed': totalPointsRedeemed,
      'tier_level': tierLevel,
      'created_at': createdAt.toIso8601String(),
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }
}
