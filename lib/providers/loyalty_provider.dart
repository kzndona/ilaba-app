import 'package:flutter/material.dart';
import 'package:ilaba/models/loyalty.dart';
import 'package:ilaba/services/loyalty_service.dart';

/// Provider for managing loyalty card state
/// This provider handles fetching, updating, and displaying loyalty points
/// independently from the booking flow
class LoyaltyProvider extends ChangeNotifier {
  final LoyaltyService loyaltyService;

  LoyaltyCard? _loyaltyCard;
  bool _isLoading = false;
  String? _errorMessage;

  LoyaltyProvider({required this.loyaltyService});

  // Getters
  LoyaltyCard? get loyaltyCard => _loyaltyCard;
  int get pointsBalance => _loyaltyCard?.pointsBalance ?? 0;
  int get totalPointsEarned => _loyaltyCard?.totalPointsEarned ?? 0;
  int get totalPointsRedeemed => _loyaltyCard?.totalPointsRedeemed ?? 0;
  String get tierLevel => _loyaltyCard?.tierLevel ?? 'bronze';
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasCard => _loyaltyCard != null;

  /// Fetch loyalty card for a user
  Future<void> fetchLoyaltyCard(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🎁 LoyaltyProvider: Fetching loyalty card for user: $userId');
      final card = await loyaltyService.getLoyaltyCard(userId);
      _loyaltyCard = card;

      if (card != null) {
        debugPrint(
          '✅ LoyaltyProvider: Loyalty card loaded - Balance: ${card.pointsBalance}',
        );
      } else {
        _errorMessage = 'No loyalty card found for user';
        debugPrint('⚠️ LoyaltyProvider: No loyalty card found');
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ LoyaltyProvider: Error fetching loyalty card: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh loyalty card from backend (useful after order creation)
  Future<void> refreshLoyaltyCard(String userId) async {
    try {
      debugPrint(
        '🔄 LoyaltyProvider: Refreshing loyalty card for user: $userId',
      );
      final card = await loyaltyService.getLoyaltyCard(userId);
      _loyaltyCard = card;

      if (card != null) {
        debugPrint(
          '✅ LoyaltyProvider: Loyalty card refreshed - New balance: ${card.pointsBalance}',
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ LoyaltyProvider: Error refreshing loyalty card: $e');
    }

    notifyListeners();
  }

  /// Redeem loyalty points
  Future<bool> redeemPoints(String userId, int points) async {
    try {
      debugPrint(
        '🎁 LoyaltyProvider: Redeeming $points points for user: $userId',
      );

      // Get current points
      final currentPoints = await loyaltyService.getLoyaltyPoints(userId);
      if (currentPoints == null) {
        throw Exception('Could not fetch current loyalty points');
      }

      if (currentPoints < points) {
        throw Exception(
          'Insufficient loyalty points: have $currentPoints, need $points',
        );
      }

      final newBalance = currentPoints - points;

      // Update in database
      await loyaltyService.updateLoyaltyPoints(userId, newBalance);

      // Update local state
      if (_loyaltyCard != null) {
        _loyaltyCard = LoyaltyCard(
          id: _loyaltyCard!.id,
          userId: _loyaltyCard!.userId,
          pointsBalance: newBalance,
          totalPointsEarned: _loyaltyCard!.totalPointsEarned,
          totalPointsRedeemed: _loyaltyCard!.totalPointsRedeemed + points,
          tierLevel: _calculateTier(newBalance),
          createdAt: _loyaltyCard!.createdAt,
          lastUpdated: DateTime.now(),
        );
        debugPrint(
          '✅ LoyaltyProvider: Points redeemed - New balance: $newBalance',
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ LoyaltyProvider: Error redeeming points: $e');
      return false;
    }
  }

  /// Add loyalty points (typically after order completion)
  Future<bool> addPoints(String userId, int points) async {
    try {
      debugPrint('🎁 LoyaltyProvider: Adding $points points for user: $userId');

      // Get current points
      final currentPoints = await loyaltyService.getLoyaltyPoints(userId);
      if (currentPoints == null) {
        throw Exception('Could not fetch current loyalty points');
      }

      final newBalance = currentPoints + points;

      // Update in database
      await loyaltyService.updateLoyaltyPoints(userId, newBalance);

      // Update local state
      if (_loyaltyCard != null) {
        _loyaltyCard = LoyaltyCard(
          id: _loyaltyCard!.id,
          userId: _loyaltyCard!.userId,
          pointsBalance: newBalance,
          totalPointsEarned: _loyaltyCard!.totalPointsEarned + points,
          totalPointsRedeemed: _loyaltyCard!.totalPointsRedeemed,
          tierLevel: _calculateTier(newBalance),
          createdAt: _loyaltyCard!.createdAt,
          lastUpdated: DateTime.now(),
        );
        debugPrint(
          '✅ LoyaltyProvider: Points added - New balance: $newBalance',
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ LoyaltyProvider: Error adding points: $e');
      return false;
    }
  }

  /// Calculate tier based on points
  String _calculateTier(int points) {
    if (points >= 1000) return 'platinum';
    if (points >= 500) return 'gold';
    if (points >= 100) return 'silver';
    return 'bronze';
  }

  /// Clear loyalty data
  void clear() {
    _loyaltyCard = null;
    _errorMessage = null;
    notifyListeners();
  }
}
