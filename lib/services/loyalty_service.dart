/// Loyalty Service
/// Manages loyalty points refresh for customers

import 'package:flutter/material.dart';
import 'package:ilaba/models/user.dart' as user_model;
import 'package:ilaba/services/auth_service.dart';

class LoyaltyService {
  final AuthService authService;

  LoyaltyService({required this.authService});

  /// Refresh loyalty points for current user
  /// Returns updated user with latest loyalty points
  Future<user_model.User?> refreshLoyaltyPoints() async {
    try {
      debugPrint('🔄 LoyaltyService: Refreshing loyalty points...');

      final user = await authService.getCurrentUser();

      if (user == null) {
        debugPrint('⚠️ LoyaltyService: No user logged in');
        return null;
      }

      debugPrint(
        '✅ LoyaltyService: Loyalty points refreshed - Points: ${user.loyaltyPoints ?? 0}',
      );

      return user;
    } catch (e) {
      debugPrint('❌ LoyaltyService: Error refreshing loyalty points: $e');
      return null;
    }
  }

  /// Get loyalty points for current user
  Future<int> getLoyaltyPoints() async {
    try {
      final user = await authService.getCurrentUser();
      return user?.loyaltyPoints ?? 0;
    } catch (e) {
      debugPrint('❌ LoyaltyService: Error getting loyalty points: $e');
      return 0;
    }
  }

  /// Determine loyalty tier based on points
  /// Tier 1: 10-19 points (5% discount)
  /// Tier 2: 20+ points (15% discount)
  String? determineLoyaltyTier(int points) {
    if (points >= 20) return 'tier2';
    if (points >= 10) return 'tier1';
    return null;
  }
}
