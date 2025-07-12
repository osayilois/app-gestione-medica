import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare_app/theme/text_styles.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  bool isSending = false;

  void sendResetEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => isSending = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMessageDialog(
        title: 'Email Sent',
        message: 'Check your inbox to reset your password.',
      );
    } on FirebaseAuthException catch (e) {
      _showMessageDialog(
        title: 'Error',
        message: e.message ?? 'Something went wrong.',
      );
    }

    setState(() => isSending = false);
  }

  void _showMessageDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              title,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset('lib/images/logonobg_medicare.png', height: 120),
                const SizedBox(height: 30),
                Text(
                  'Forgot Password?',
                  style: AppTextStyles.title1(color: Colors.black),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter your email to receive a reset link.',
                  style: AppTextStyles.subtitle(color: Colors.black),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.body(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: AppTextStyles.body(color: Colors.grey[700]!),
                    prefixIcon: Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.grey[200],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.red, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                isSending
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: sendResetEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Send Reset Link',
                        style: AppTextStyles.buttons(color: Colors.white),
                      ),
                    ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Back to Login',
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
