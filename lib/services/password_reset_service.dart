import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

abstract class PasswordResetService {
  Future<void> requestPasswordReset(String email);
}

class PasswordResetServiceImpl implements PasswordResetService {
  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      debugPrint('🔑 Requesting password reset for: $email');

      // Use the main Supabase client to send password reset email
      // resetPasswordForEmail works with standard credentials and sends the email
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://katflix-ilaba.vercel.app/auth/reset-password',
      );

      debugPrint('✅ Password reset email sent successfully');
    } on AuthException catch (e) {
      debugPrint('❌ AuthException during reset: ${e.statusCode} - ${e.message}');

      if (e.statusCode == '400' || e.statusCode == '422') {
        throw Exception('No account found with this email address');
      }
      throw Exception(e.message);
    } catch (e) {
      debugPrint('❌ Password reset error: ${e.runtimeType} - $e');

      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(10);
      }
      throw Exception(errorMsg);
    }
  }
}
