import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare_app/pages/home/home_page.dart';
import 'package:medicare_app/pages/auth/register_page.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/pages/admin/admin_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  /* void signIn() async {
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Login Failed',
                style: AppTextStyles.subtitle(color: Colors.black),
              ),
              content: Text(
                e.message ?? 'Unknown error',
                style: AppTextStyles.body(color: Colors.black),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'OK',
                    style: AppTextStyles.buttons(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
      );
    }
    setState(() => isLoading = false);
  } */

  void signIn() async {
    setState(() => isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final email = userCredential.user?.email;

      if (email == 'admin@medicare.com') {
        // Vai alla home admin
        Navigator.pushReplacementNamed(context, '/admin-home');
      } else {
        // Vai alla home normale
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Login Failed',
                style: AppTextStyles.subtitle(color: Colors.black),
              ),
              content: Text(
                e.message ?? 'Unknown error',
                style: AppTextStyles.body(color: Colors.black),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'OK',
                    style: AppTextStyles.buttons(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
      );
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset('lib/images/logonobg_medicare.png', height: 120),
                const SizedBox(height: 30),
                Text(
                  'Welcome Back!',
                  style: AppTextStyles.title1(color: Colors.black),
                ),
                const SizedBox(height: 10),
                Text(
                  'Login to continue',
                  style: AppTextStyles.subtitle(color: Colors.black),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  style: AppTextStyles.body(
                    color: Colors.black,
                  ), // Font del testo inserito
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: AppTextStyles.body(color: Colors.grey[700]!),
                    prefixIcon: Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.grey[200], // sfondo leggero
                    // bordo quando il cambo non è selezionato
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1,
                      ),
                    ),

                    // bordo quando il campo è selezionato
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                        width: 1.5,
                      ),
                    ),

                    // bordo in stato di errore
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  style: AppTextStyles.body(
                    color: Colors.black,
                  ), // Font del testo inserito
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: AppTextStyles.body(color: Colors.grey[700]!),
                    prefixIcon: Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.grey[200], // sfondo leggero
                    // bordo quando il campo non è selezionato
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1,
                      ),
                    ),

                    // bordo quando il campo è attivo
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                        width: 1.5,
                      ),
                    ),

                    // Bordo in stato di errore (opzionale)
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: AppTextStyles.buttons(color: Colors.white),
                      ),
                    ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: Text(
                    "Don't have an account? Register here",
                    style: AppTextStyles.link(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
