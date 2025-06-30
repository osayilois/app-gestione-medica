// lib/pages/doctor_profile_page.dart

import 'package:flutter/material.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/pages/appointments/appointment_page.dart';
import 'package:url_launcher/url_launcher.dart';

enum InfoType { phone, email, address, hours }

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
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          name,
          style: AppTextStyles.title2(color: Colors.grey.shade800),
        ),
        iconTheme: IconThemeData(color: Colors.grey.shade800),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Immagine rotonda, leggermente più grande
            Center(
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.grey[200],
                backgroundImage: AssetImage(imagePath),
              ),
            ),
            const SizedBox(height: 16),
            // Nome centrato
            Text(
              name,
              style: AppTextStyles.title1(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Specializzazione centrata
            Text(
              specialty,
              style: AppTextStyles.subtitle(color: Colors.grey[700]!),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Rating centrato
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.yellow[700], size: 20),
                const SizedBox(width: 4),
                Text(rating, style: AppTextStyles.body(color: Colors.black)),
              ],
            ),
            const SizedBox(height: 24),

            // Bio centrata
            if (bio.isNotEmpty) ...[
              Text(
                bio,
                style: AppTextStyles.body(color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],

            // Informazioni aggiuntive
            if (address.isNotEmpty) ...[
              _infoRow(
                Icons.location_on,
                address,
                type: InfoType.address,
                context: context,
              ),
              const SizedBox(height: 12),
            ],
            if (phone.isNotEmpty) ...[
              _infoRow(
                Icons.phone,
                phone,
                type: InfoType.phone,
                context: context,
              ),
              const SizedBox(height: 12),
            ],
            if (email.isNotEmpty) ...[
              _infoRow(
                Icons.email,
                email,
                type: InfoType.email,
                context: context,
              ),
              const SizedBox(height: 12),
            ],
            if (hours.isNotEmpty) ...[
              _infoRow(Icons.access_time, hours, context: context),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 24),
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
                    borderRadius: BorderRadius.circular(35),
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

  Widget _infoRow(
    IconData iconData,
    String text, {
    InfoType type = InfoType.hours,
    required BuildContext context,
  }) {
    // Per “hours”: solo testo senza ripple
    if (type == InfoType.hours) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppTextStyles.body(color: Colors.black)),
          ),
        ],
      );
    }

    // Per gli altri tipi, usiamo InkWell dentro Material per visivo
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          Uri uri;
          try {
            switch (type) {
              case InfoType.phone:
                // rimuovi spazi o parentesi se presenti:
                final digits = text.replaceAll(RegExp(r'\s+|\(|\)|\-'), '');
                uri = Uri(scheme: 'tel', path: digits);
                break;
              case InfoType.email:
                final mail = text.trim();
                uri = Uri(scheme: 'mailto', path: mail);
                break;
              case InfoType.address:
                final encoded = Uri.encodeComponent(text.trim());
                uri = Uri.parse(
                  'https://www.google.com/maps/search/?api=1&query=$encoded',
                );
                break;
              case InfoType.hours:
                return;
            }
            // Proviamo ad aprire direttamente
            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Non è possibile aprire: $text')),
              );
            }
          } catch (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Errore tentando di aprire: $text')),
            );
          }
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(iconData, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.body(color: Colors.black).copyWith(
                    decoration:
                        TextDecoration
                            .underline, // per far capire che è cliccabile
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
