import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medicare_app/pages/profile/medical_card_page.dart';
import 'package:medicare_app/theme/text_styles.dart';

class MedicalBanner extends StatelessWidget {
  final bool hasMedical;
  final VoidCallback onGetStarted;

  const MedicalBanner({
    super.key,
    required this.hasMedical,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // start per allineare a sinistra
        children: [
          if (!hasMedical) ...[
            // Banner solo per il primo login
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.pink[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: Lottie.network(
                      'https://assets2.lottiefiles.com/packages/lf20_tutvdkg0.json',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How do you feel?',
                          style: AppTextStyles.subtitle(color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fill out your medical card right now',
                          style: AppTextStyles.body(color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: onGetStarted,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Get Started',
                              style: AppTextStyles.buttons(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Titolo sempre allineato a sinistra
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Let's find your \nDoctor",
              style: AppTextStyles.bigtitle(color: Colors.black),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
