// lib/pages/doctor_profile_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/pages/appointments/appointment_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medicare_app/widgets/chat_box.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
            Center(
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.grey[200],
                backgroundImage: AssetImage(imagePath),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: AppTextStyles.title1(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              specialty,
              style: AppTextStyles.subtitle(color: Colors.grey[700]!),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.yellow[700], size: 20),
                const SizedBox(width: 4),
                Text(rating, style: AppTextStyles.body(color: Colors.black)),
              ],
            ),
            const SizedBox(height: 24),
            if (bio.isNotEmpty) ...[
              Text(
                bio,
                style: AppTextStyles.body(color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
            if (address.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _infoRow(
                  Icons.location_on,
                  address,
                  type: InfoType.address,
                  context: context,
                ),
              ),
              //const SizedBox(height: 16),
            ],

            if (phone.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _infoRow(
                  Icons.phone,
                  phone,
                  type: InfoType.phone,
                  context: context,
                ),
              ),
            if (email.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _infoRow(
                  Icons.email,
                  email,
                  type: InfoType.email,
                  context: context,
                ),
              ),
            if (hours.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _infoRow(Icons.access_time, hours, context: context),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ChatBox(doctorName: name),
                    );
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(
                      //Icons.chat_bubble_outline,
                      FontAwesomeIcons.comment,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => AppointmentPage(
                                doctorName: name,
                                doctorSpecialty: specialty,
                                doctorImagePath: imagePath,
                              ),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          Uri? uri;
          try {
            switch (type) {
              case InfoType.phone:
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
                  Platform.isIOS
                      ? 'https://maps.apple.com/?q=$encoded'
                      : 'https://www.google.com/maps/search/?api=1&query=$encoded',
                );
                break;
              case InfoType.hours:
                return; // Non fa nulla
            }

            if (uri != null) {
              final launched = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
              if (!launched) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Non è possibile aprire: $text')),
                );
              }
            }
          } catch (e) {
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
                  style: AppTextStyles.body(
                    color: Colors.black,
                  ).copyWith(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
