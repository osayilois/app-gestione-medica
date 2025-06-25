// lib/widgets/logout_dialog.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medicare_app/theme/text_styles.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 120,
            child: Lottie.asset('assets/animations/logout.json', repeat: false),
          ),
          const SizedBox(height: 12),
          Text(
            'Are you sure you want to log out?',
            textAlign: TextAlign.center,
            style: AppTextStyles.title2(color: Colors.black),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 150,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepPurple[300],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTextStyles.buttons(),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.buttons(color: Colors.deepPurple[300]!),
            ),
          ),
        ],
      ),
    );
  }
}
