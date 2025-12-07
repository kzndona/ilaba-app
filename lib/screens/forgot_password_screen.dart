import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget{
  const ForgotPasswordScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                  ),
                ),
                SizedBox(height: 24.0),
                
                ElevatedButton(
                    onPressed: () {
                      // TODO: Handle reset password
                    }, 
                    child: const Text('Send Reset Link'),
                ),
                SizedBox(height: 16.0),
                
                OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    }, child: const Text('Return to Login'))
              ],
            ),
          )),
    );
  }
}