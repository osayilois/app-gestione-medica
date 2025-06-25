// lib/pages/doctor_detail_page.dart

import 'package:flutter/material.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/pages/appointments/appointment_page.dart';

class DoctorDetailPage extends StatelessWidget {
  final String name;
  final String specialty;
  final String imagePath;
  final String rating;

  const DoctorDetailPage({
    super.key,
    required this.name,
    required this.specialty,
    required this.imagePath,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          name,
          style: AppTextStyles.title2(color: Colors.grey.shade800),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(75),
              child: Image.asset(
                imagePath,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(name, style: AppTextStyles.title1(color: Colors.black)),
            Text(
              specialty,
              style: AppTextStyles.subtitle(color: Colors.grey[700]!),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.yellow[700], size: 20),
                const SizedBox(width: 4),
                Text(rating, style: AppTextStyles.body(color: Colors.black)),
              ],
            ),
            const SizedBox(height: 24),
            // Qui potrai aggiungere tutte le info aggiuntive sul medico
            Text(
              '$name è uno specialista in $specialty con anni di esperienza. '
              'Qui puoi aggiungere descrizione, titolo, indirizzo dello studio, ecc.',
              style: AppTextStyles.body(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AppointmentPage(doctorName: name),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Book an Appointment',
                  style: AppTextStyles.buttons(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
