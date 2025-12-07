import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ilaba/models/user.dart' as models;

abstract class AuthService {
  Future<models.User> login(String email, String password);
  Future<models.User> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    String? middleName,
    String? address,
    required String password,
  });
  Future<void> logout();
  Future<models.User?> getCurrentUser();
  Future<void> resetPassword(String email);
  Future<bool> isLoggedIn();
}

class AuthServiceImpl implements AuthService {
  final SupabaseClient supabaseClient;

  AuthServiceImpl({required this.supabaseClient});

  @override
  Future<models.User> login(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final authUser = response.user;
      if (authUser == null) {
        throw Exception('Login failed: No user returned');
      }

      // Fetch user profile from customers table
      final userData = await supabaseClient
          .from('customers')
          .select()
          .eq('auth_id', authUser.id)
          .single();

      return models.User.fromJson(userData);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<models.User> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    String? middleName,
    String? address,
    required String password,
  }) async {
    try {
      // Create auth account
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      final authUser = response.user;
      if (authUser == null) {
        throw Exception('Signup failed: No user returned');
      }

      // Create user profile in customers table
      final user = models.User(
        id: authUser.id,
        authId: authUser.id,
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        emailAddress: email,
        phoneNumber: phoneNumber,
        address: address,
        createdAt: DateTime.now(),
      );

      await supabaseClient.from('customers').insert(user.toJson());

      return user;
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<models.User?> getCurrentUser() async {
    try {
      final authUser = supabaseClient.auth.currentUser;
      if (authUser == null) {
        return null;
      }

      final userData = await supabaseClient
          .from('customers')
          .select()
          .eq('auth_id', authUser.id)
          .single();

      return models.User.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return supabaseClient.auth.currentUser != null;
  }
}
