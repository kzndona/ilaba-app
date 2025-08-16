import 'package:flutter/material.dart';
import 'package:ilaba/home_menu_screen.dart';
import 'package:ilaba/signup_screen.dart';
import 'package:ilaba/forgot_password_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                  'iLaba',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              const TextField(
                decoration: InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),

              const TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: const Text('Forgot Password?'),
                )
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                  onPressed: () {
                    // TODO: Handle login

                    // TESTING: Navigates to Home Menu
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeMenuScreen())
                    );
                  },
                  child: const Text('Login')),
              const SizedBox(height: 16),

              OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: const Text('Sign up')),
            ],
          ),
      ),
    );
  }
}