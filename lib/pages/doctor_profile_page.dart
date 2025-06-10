// lib/pages/doctor_profile_page.dart

import 'package:flutter/material.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/pages/appointment_page.dart';

class DoctorProfilePage extends StatelessWidget {
  final String name;
  final String specialty;
  final String imagePath;
  final String rating;
  final String bio;
  final String address;
  final String phone;
  final String email;
  final String hours;

  const DoctorProfilePage({
    Key? key,
    required this.name,
    required this.specialty,
    required this.imagePath,
    required this.rating,
    this.bio = '',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.hours = '',
  }) : super(key: key);

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
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Immagine rotonda del dottore
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

            // Bio se presente
            if (bio.isNotEmpty) ...[
              Text(
                bio,
                style: AppTextStyles.body(color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],

            // Indirizzo se presente
            if (address.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address,
                      style: AppTextStyles.body(color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Telefono se presente
            if (phone.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(phone, style: AppTextStyles.body(color: Colors.black)),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Email se presente
            if (email.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.email, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(email, style: AppTextStyles.body(color: Colors.black)),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Orari se presenti
            if (hours.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.access_time, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hours,
                      style: AppTextStyles.body(color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Pulsante “Book an Appointment”
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
