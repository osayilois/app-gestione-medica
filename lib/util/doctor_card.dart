// lib/util/doctor_card.dart

import 'package:flutter/material.dart';
import 'package:medicare_app/theme/text_styles.dart';

class DoctorCard extends StatelessWidget {
  final String doctorImagePath;
  final String rating;
  final String doctorName;
  final String doctorProfession;

  const DoctorCard({
    super.key,
    required this.doctorImagePath,
    required this.rating,
    required this.doctorName,
    required this.doctorProfession,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.deepPurple[50],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // immagine del dottore
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                doctorImagePath,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            // rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.yellow[700], size: 16),
                const SizedBox(width: 4),
                Text(rating, style: AppTextStyles.body(color: Colors.black)),
              ],
            ),
            const SizedBox(height: 8),
            // nome
            Text(
              doctorName,
              style: AppTextStyles.buttons(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // professione
            Text(
              doctorProfession,
              style: AppTextStyles.body(color: Colors.grey[700]!),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
