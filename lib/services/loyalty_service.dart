import 'package:ilaba/models/loyalty.dart';

abstract class LoyaltyService {
  Future<LoyaltyCard?> getLoyaltyCard(String userId);
  Future<void> redeemPoints(String userId, int points);
  Future<void> addPoints(String userId, int points);
}

class LoyaltyServiceImpl implements LoyaltyService {
  // TODO: Implement with actual API calls to Supabase
  // Example endpoint: GET /loyalty/:userId
  // Example endpoint: POST /loyalty/:userId/redeem
  // Example endpoint: POST /loyalty/:userId/add-points

  @override
  Future<LoyaltyCard?> getLoyaltyCard(String userId) async {
    throw UnimplementedError('getLoyaltyCard() not implemented');
  }

  @override
  Future<void> redeemPoints(String userId, int points) async {
    throw UnimplementedError('redeemPoints() not implemented');
  }

  @override
  Future<void> addPoints(String userId, int points) async {
    throw UnimplementedError('addPoints() not implemented');
  }
}
