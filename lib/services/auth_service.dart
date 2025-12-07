import 'package:ilaba/models/user.dart';

abstract class AuthService {
  Future<User> login(String email, String password);
  Future<User> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String address,
    required String password,
  });
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> resetPassword(String email);
}

class AuthServiceImpl implements AuthService {
  // TODO: Implement with actual API calls to Supabase
  // Example endpoint: POST /auth/login
  // Example endpoint: POST /auth/signup
  // Example endpoint: POST /auth/logout
  // Example endpoint: GET /auth/me
  // Example endpoint: POST /auth/forgot-password

  @override
  Future<User> login(String email, String password) async {
    throw UnimplementedError('login() not implemented');
  }

  @override
  Future<User> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String address,
    required String password,
  }) async {
    throw UnimplementedError('signup() not implemented');
  }

  @override
  Future<void> logout() async {
    throw UnimplementedError('logout() not implemented');
  }

  @override
  Future<User?> getCurrentUser() async {
    throw UnimplementedError('getCurrentUser() not implemented');
  }

  @override
  Future<void> resetPassword(String email) async {
    throw UnimplementedError('resetPassword() not implemented');
  }
}
