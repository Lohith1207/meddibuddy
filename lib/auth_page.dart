import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/homepage.dart';
import '/login_page.dart';
import '/register_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // ✅ User is already logged in — go to Meddibuddy home
      return const myhomepage();
    }

    // 🚪 Not logged in — show login/register options
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Meddibuddy',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text(
                  'Register',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
