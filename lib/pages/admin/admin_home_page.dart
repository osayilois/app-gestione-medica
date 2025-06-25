import 'package:flutter/material.dart';
import 'package:medicare_app/pages/admin/admin_prescription_page.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                Text(
                  "Are you sure you want to log out?",
                  style: AppTextStyles.subtitle(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Annulla",
                        style: AppTextStyles.buttons(color: Colors.deepPurple),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      onPressed: () async {
                        Navigator.pop(context); // Chiudi dialog
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      },
                      child: Text(
                        "Logout",
                        style: AppTextStyles.buttons(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Area', style: AppTextStyles.title2()),
        backgroundColor: Colors.deepPurple.shade200,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Logout',
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Admin 👩‍⚕️',
              style: AppTextStyles.bigtitle(color: Colors.deepPurple),
            ),
            const SizedBox(height: 20),
            Text(
              "Easily manage patients' requests.",
              style: AppTextStyles.subtitle(),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade300,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(FontAwesomeIcons.filePrescription),
              label: Text(
                'Prescriptions',
                style: AppTextStyles.buttons(color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminPrescriptionPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Altri pulsanti qui in futuro
          ],
        ),
      ),
    );
  }
}
