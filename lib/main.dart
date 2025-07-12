import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:medicare_app/pages/home/home_page.dart';
import 'package:medicare_app/pages/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare_app/pages/admin/admin_home_page.dart';
import 'package:medicare_app/pages/auth/forgot_password_page.dart';
import 'package:medicare_app/util/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Rotta per pagina admin
      routes: {
        '/admin-home': (context) => const AdminHomePage(),
        '/login': (context) => const LoginPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
      },

      // Intro splash screen
      home: SplashScreen(
        duration: const Duration(seconds: 3),
        nextScreen: (_) => const AuthGate(),
      ),
    );
  }
}

/// Separa la logica di autenticazione per il nextScreen della splash
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const HomePage(); // Utente loggato
        } else {
          return const LoginPage(); // Utente non loggato
        }
      },
    );
  }
}
