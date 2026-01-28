/// Mobile Order Creation Service
/// Submits completed orders to backend API

import 'package:flutter/material.dart';
import 'package:ilaba/models/order_models.dart';
import 'package:ilaba/services/api_client.dart';

class MobileOrderService {
  final ApiClient apiClient;

  MobileOrderService({required this.apiClient});

  /// Create a booking order and submit to backend
  /// Returns OrderResponse with order_id and receipt details
  Future<OrderResponse> createOrder(BookingOrder order) async {
    try {
      debugPrint('📤 MobileOrderService: Submitting order...');
      debugPrint('   Order data: ${order.toJson()}');

      final response = await apiClient.post(
        '/api/orders/mobile/create',
        order.toJson(),
      );

      debugPrint('📥 MobileOrderService: Response received');
      debugPrint('   Response: $response');

      final orderResponse = OrderResponse.fromJson(response);

      if (!orderResponse.success) {
        throw Exception(orderResponse.error ?? 'Failed to create order');
      }

      debugPrint(
        '✅ MobileOrderService: Order created successfully - ID: ${orderResponse.orderId}',
      );

      return orderResponse;
    } catch (e) {
      debugPrint('❌ MobileOrderService: Error creating order: $e');
      rethrow;
    }
  }
}
