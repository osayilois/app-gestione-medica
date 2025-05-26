import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare_app/pages/home_page.dart';
import 'package:medicare_app/theme/text_styles.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  void register() async {
    if (passwordController.text != confirmPasswordController.text) {
      showError('Passwords do not match.');
      return;
    }

    if (nameController.text.trim().isEmpty ||
        surnameController.text.trim().isEmpty) {
      showError('Name and Surname are required.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Unione e capitalizzazione Nome + Cognome
      String fullName =
          '${nameController.text.trim()} ${surnameController.text.trim()}';
      String capitalizedFullName = capitalizeFullName(fullName);

      await userCredential.user!.updateDisplayName(capitalizedFullName);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? 'Registration failed.');
    }

    setState(() => isLoading = false);
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              'Error',
              style: AppTextStyles.subtitle(color: Colors.black),
            ),
            content: Text(
              message,
              style: AppTextStyles.body(color: Colors.black),
            ),
            actions: [
              TextButton(
                child: Text(
                  'OK',
                  style: AppTextStyles.buttons(color: Colors.deepPurple),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  InputDecoration buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.body(color: Colors.grey[700]!),
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey[200],
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.deepPurple, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
    );
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
                Image.asset('lib/images/logonobg_medicare.png', height: 1),
                const SizedBox(height: 30),
                Text(
                  'Create Account',
                  style: AppTextStyles.title1(color: Colors.black),
                ),
                const SizedBox(height: 10),
                Text(
                  'Register to get started',
                  style: AppTextStyles.subtitle(color: Colors.black),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: nameController,
                  style: AppTextStyles.body(color: Colors.black),
                  decoration: buildInputDecoration('Name', Icons.person),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: surnameController,
                  style: AppTextStyles.body(color: Colors.black),
                  decoration: buildInputDecoration(
                    'Surname',
                    Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  style: AppTextStyles.body(color: Colors.black),
                  decoration: buildInputDecoration('Email', Icons.email),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: AppTextStyles.body(color: Colors.black),
                  decoration: buildInputDecoration('Password', Icons.lock),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  style: AppTextStyles.body(color: Colors.black),
                  decoration: buildInputDecoration(
                    'Confirm Password',
                    Icons.lock_outline,
                  ),
                ),
                const SizedBox(height: 30),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Register',
                        style: AppTextStyles.buttons(color: Colors.white),
                      ),
                    ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Already have an account? Login here',
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

String capitalizeFullName(String fullName) {
  return fullName
      .split(' ')
      .map(
        (str) =>
            str.isNotEmpty
                ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}'
                : '',
      )
      .join(' ');
}
