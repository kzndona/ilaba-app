import 'package:ilaba/models/loyalty.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

abstract class LoyaltyService {
  Future<LoyaltyCard?> getLoyaltyCard(String userId);
  Future<int?> getLoyaltyPoints(String userId);
  Future<void> updateLoyaltyPoints(String userId, int newPoints);
}

class LoyaltyServiceImpl implements LoyaltyService {
  final SupabaseClient supabaseClient;

  LoyaltyServiceImpl({required this.supabaseClient});

  @override
  Future<LoyaltyCard?> getLoyaltyCard(String userId) async {
    try {
      debugPrint('🎁 LoyaltyService: Fetching loyalty for user: $userId');
      
      // Query customers table by customer id (not auth_id)
      final response = await supabaseClient
          .from('customers')
          .select()
          .eq('id', userId)
          .single();

      final loyaltyPoints = response['loyalty_points'] as int? ?? 0;
      debugPrint('✅ LoyaltyService: Retrieved loyalty points - Balance: $loyaltyPoints');
      
      // Return a LoyaltyCard object constructed from customer data
      return LoyaltyCard(
        id: response['id'] as String,
        userId: response['id'] as String,
        pointsBalance: loyaltyPoints,
        totalPointsEarned: loyaltyPoints, // Not tracking separately in this schema
        totalPointsRedeemed: 0, // Not tracking separately in this schema
        tierLevel: _calculateTier(loyaltyPoints),
        createdAt: response['created_at'] != null
            ? DateTime.parse(response['created_at'] as String)
            : DateTime.now(),
        lastUpdated: response['updated_at'] != null
            ? DateTime.parse(response['updated_at'] as String)
            : null,
      );
    } catch (e) {
      debugPrint('❌ LoyaltyService: Error fetching loyalty card: $e');
      return null;
    }
  }

  @override
  Future<int?> getLoyaltyPoints(String userId) async {
    try {
      debugPrint('🎁 LoyaltyService: Fetching loyalty points for user: $userId');
      
      final response = await supabaseClient
          .from('customers')
          .select('loyalty_points')
          .eq('id', userId)
          .single();

      final points = response['loyalty_points'] as int? ?? 0;
      debugPrint('✅ LoyaltyService: Retrieved $points loyalty points');
      return points;
    } catch (e) {
      debugPrint('❌ LoyaltyService: Error fetching loyalty points: $e');
      return null;
    }
  }

  @override
  Future<void> updateLoyaltyPoints(String userId, int newPoints) async {
    try {
      debugPrint('🎁 LoyaltyService: Updating loyalty points for user: $userId to $newPoints');
      
      await supabaseClient
          .from('customers')
          .update({
            'loyalty_points': newPoints,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      debugPrint('✅ LoyaltyService: Updated loyalty points to $newPoints');
    } catch (e) {
      debugPrint('❌ LoyaltyService: Error updating loyalty points: $e');
      rethrow;
    }
  }

  /// Calculate tier based on points
  String _calculateTier(int points) {
    if (points >= 1000) return 'platinum';
    if (points >= 500) return 'gold';
    if (points >= 100) return 'silver';
    return 'bronze';
  }
}

