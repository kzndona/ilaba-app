import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class ApiClient {
  Future<Map<String, dynamic>> get(String endpoint);
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body);
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body);
  Future<void> delete(String endpoint);
  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body,
  );
}

class ApiClientImpl implements ApiClient {
  final SupabaseClient supabase;

  ApiClientImpl({required this.supabase});

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      debugPrint('📡 ApiClient.get($endpoint)');

      // Route to appropriate Supabase table based on endpoint
      if (endpoint == '/api/pos/services') {
        final response = await supabase
            .from('services')
            .select()
            .eq('is_active', true);

        debugPrint('📡 GET $endpoint response: $response');

        return {'success': true, 'services': response};
      } else if (endpoint == '/api/pos/products') {
        final response = await supabase
            .from('products')
            .select()
            .eq('is_active', true);

        return {'success': true, 'products': response};
      }

      throw Exception('Unknown endpoint: $endpoint');
    } catch (e) {
      debugPrint('❌ ApiClient.get() error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      debugPrint('📡 ApiClient.post($endpoint) body: $body');

      // Get the backend API URL from environment
      // For API calls, use BACKEND_API_URL (Next.js server)
      // For Supabase table queries, use SUPABASE_URL
      final backendUrl = dotenv.env['BACKEND_API_URL'] ?? '';
      if (backendUrl.isEmpty) {
        throw Exception('BACKEND_API_URL not configured in .env file');
      }

      // Build the full API URL
      final url = Uri.parse('$backendUrl$endpoint');

      debugPrint('📡 ApiClient.post() URL: $url');

      // Get the session token for authentication (if available)
      final session = supabase.auth.currentSession;
      final authToken = session?.accessToken ?? '';

      // Make the HTTP POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(body),
      );

      debugPrint('📡 ApiClient.post() response status: ${response.statusCode}');
      debugPrint('📡 ApiClient.post() response body: ${response.body}');

      // Parse the response
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ ApiClient.post() success: $responseData');
        return responseData;
      } else {
        debugPrint('❌ ApiClient.post() error status ${response.statusCode}: $responseData');
        return {
          'success': false,
          'error': responseData['error'] ?? 'Request failed with status ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('❌ ApiClient.post() error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    throw UnimplementedError('put() not implemented');
  }

  @override
  Future<void> delete(String endpoint) async {
    throw UnimplementedError('delete() not implemented');
  }

  @override
  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    throw UnimplementedError('patch() not implemented');
  }
}
