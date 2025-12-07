abstract class ApiClient {
  Future<Map<String, dynamic>> get(String endpoint);
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body);
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body);
  Future<void> delete(String endpoint);
  Future<Map<String, dynamic>> patch(
      String endpoint, Map<String, dynamic> body);
}

class ApiClientImpl implements ApiClient {
  // TODO: Implement with http or dio package
  // Configure base URL for Supabase API
  // Add authentication headers
  // Handle error responses

  static const String baseUrl = 'YOUR_SUPABASE_URL/rest/v1';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    throw UnimplementedError('get() not implemented');
  }

  @override
  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    throw UnimplementedError('post() not implemented');
  }

  @override
  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> body) async {
    throw UnimplementedError('put() not implemented');
  }

  @override
  Future<void> delete(String endpoint) async {
    throw UnimplementedError('delete() not implemented');
  }

  @override
  Future<Map<String, dynamic>> patch(
      String endpoint, Map<String, dynamic> body) async {
    throw UnimplementedError('patch() not implemented');
  }
}
