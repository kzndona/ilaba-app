/// Services Repository
/// Fetches laundry services from backend API
/// Caches results locally for offline support

import 'package:flutter/material.dart';
import 'package:ilaba/models/order_models.dart';
import 'package:ilaba/services/api_client.dart';

class ServicesRepository {
  final ApiClient apiClient;
  List<Service>? _cachedServices;

  ServicesRepository({required this.apiClient});

  /// Get all active services
  /// Returns cached result if available, otherwise fetches from API
  Future<List<Service>> getServices() async {
    try {
      // Return cached if available
      if (_cachedServices != null && _cachedServices!.isNotEmpty) {
        debugPrint('✅ ServicesRepository: Returning cached services');
        return _cachedServices!;
      }

      debugPrint('🔄 ServicesRepository: Fetching services from API...');

      final response = await apiClient.get('/api/pos/services');

      debugPrint('📡 ServicesRepository: API Response: $response');

      if (response['success'] != true) {
        throw Exception('Failed to fetch services: ${response['error']}');
      }

      final servicesData = response['services'] as List?;
      if (servicesData == null) {
        throw Exception('No services data in response');
      }

      final services = servicesData
          .map((s) => Service.fromJson(s as Map<String, dynamic>))
          .toList();

      // Cache results
      _cachedServices = services;

      debugPrint(
        '✅ ServicesRepository: Fetched ${services.length} services: ${services.map((s) => '${s.serviceType}/${s.tier}:${s.name}').join(', ')}',
      );
      return services;
    } catch (e) {
      debugPrint('❌ ServicesRepository: Error fetching services: $e');
      rethrow;
    }
  }

  /// Clear cache (useful for refresh)
  void clearCache() {
    _cachedServices = null;
    debugPrint('🧹 ServicesRepository: Cache cleared');
  }

  /// Get specific service by type and tier
  Future<Service?> getServiceByTypeAndTier(
    String serviceType,
    String? tier,
  ) async {
    final services = await getServices();
    return services.firstWhere(
      (s) => s.serviceType == serviceType && s.tier == tier,
      orElse: () => services.firstWhere(
        (s) => s.serviceType == serviceType,
        orElse: () => throw Exception('Service not found: $serviceType'),
      ),
    );
  }
}
