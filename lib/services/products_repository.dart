/// Products Repository
/// Fetches retail products from backend API
/// Caches results locally for offline support

import 'package:flutter/material.dart';
import 'package:ilaba/models/order_models.dart';
import 'package:ilaba/services/api_client.dart';

class ProductsRepository {
  final ApiClient apiClient;
  List<Product>? _cachedProducts;

  ProductsRepository({required this.apiClient});

  /// Get all active products with pagination
  /// Returns cached result if available, otherwise fetches from API
  Future<List<Product>> getProducts({int limit = 100, int offset = 0}) async {
    try {
      // Return cached if available and offset is 0 (initial load)
      if (offset == 0 &&
          _cachedProducts != null &&
          _cachedProducts!.isNotEmpty) {
        debugPrint('✅ ProductsRepository: Returning cached products');
        return _cachedProducts!;
      }

      debugPrint(
        '🔄 ProductsRepository: Fetching products from API (limit: $limit, offset: $offset)...',
      );

      final response = await apiClient.get('/api/pos/products');

      debugPrint('📡 ProductsRepository: API Response: $response');

      if (response['success'] != true) {
        throw Exception('Failed to fetch products: ${response['error']}');
      }

      final productsData = response['products'] as List?;
      if (productsData == null) {
        throw Exception('No products data in response');
      }

      final products = productsData
          .map((p) => Product.fromJson(p as Map<String, dynamic>))
          .toList();

      // Cache results if offset is 0
      if (offset == 0) {
        _cachedProducts = products;
      }

      debugPrint(
        '✅ ProductsRepository: Fetched ${products.length} products (total: ${response['total']})',
      );
      return products;
    } catch (e) {
      debugPrint('❌ ProductsRepository: Error fetching products: $e');
      rethrow;
    }
  }

  /// Get product by ID
  Future<Product?> getProductById(String productId) async {
    final products = await getProducts();
    try {
      return products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  /// Search products by name
  Future<List<Product>> searchProducts(String query) async {
    final products = await getProducts();
    final lowerQuery = query.toLowerCase();
    return products
        .where((p) => p.itemName.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Clear cache (useful for refresh)
  void clearCache() {
    _cachedProducts = null;
    debugPrint('🧹 ProductsRepository: Cache cleared');
  }
}
