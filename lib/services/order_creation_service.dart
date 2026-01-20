import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ilaba/models/order_models.dart';

abstract class OrderCreationService {
  Future<CreateOrderResponse> createOrder(CreateOrderRequest request);
}

class OrderCreationServiceImpl implements OrderCreationService {
  static const String baseUrl = 'https://katflix-ilaba.vercel.app';
  static const String endpoint = '/api/orders/transactional-create';

  @override
  Future<CreateOrderResponse> createOrder(CreateOrderRequest request) async {
    try {
      debugPrint('📝 Creating order for customer: ${request.customer.id}');

      final payload = request.toJson();
      debugPrint('📤 Order payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Order creation request timed out'),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

        final result = CreateOrderResponse.fromJson(jsonResponse);

        if (result.success) {
          debugPrint('✅ Order created successfully: ${result.orderId}');
          return result;
        } else {
          debugPrint('❌ Order creation failed: ${result.error}');
          throw Exception(result.error ?? 'Order creation failed');
        }
      } else {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMsg = errorBody['error'] ?? 
            'Order creation failed with status ${response.statusCode}';
        debugPrint('❌ HTTP error: $errorMsg');
        
        // Check for insufficient items error
        if (errorBody['insufficientItems'] != null) {
          return CreateOrderResponse(
            success: false,
            orderId: '',
            error: errorMsg,
            insufficientItems: List<Map<String, dynamic>>.from(
              errorBody['insufficientItems'] as List,
            ),
          );
        }
        
        throw Exception(errorMsg);
      }
    } on http.ClientException catch (e) {
      debugPrint('❌ HTTP Client error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('❌ Order creation error: ${e.runtimeType} - $e');
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(10);
      }
      throw Exception(errorMsg);
    }
  }
}
