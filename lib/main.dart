import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FORCE fullscreen + lock to portrait
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Supabase init
  await Supabase.initialize(
    url: 'https://pmmilydpjjoonitslhjf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBtbWlseWRwampvb25pdHNsaGpmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIwNTU1NjYsImV4cCI6MjA2NzYzMTU2Nn0.Hxyl5B4t6KaIY1kJ6Qs07A4tYZcYHSELStMxnMLIy3k',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health AI',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        primaryColor: Colors.grey[900],
        cardColor: Colors.grey[850],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const AuthPage(),
    );
  }
}
