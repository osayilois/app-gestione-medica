// lib/pages/specialist_page.dart

import 'package:flutter/material.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/util/doctor_card.dart';
import 'package:medicare_app/pages/doctor_detail_page.dart';

class SpecialistPage extends StatelessWidget {
  final String specialty;
  final List<Map<String, String>> doctors;

  const SpecialistPage({
    super.key,
    required this.specialty,
    required this.doctors,
  });

  @override
  Widget build(BuildContext context) {
    final filtered =
        specialty == 'All'
            ? doctors
            : doctors.where((d) => d['specialty'] == specialty).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          specialty == 'All' ? 'All Doctors' : specialty,
          style: AppTextStyles.title2(color: Colors.grey.shade800),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) {
          final d = filtered[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap:
                  () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder:
                          (_) => DoctorDetailPage(
                            name: d['name']!,
                            specialty: d['specialty']!,
                            imagePath: d['image']!,
                            rating: d['rating']!,
                          ),
                    ),
                  ),
              child: DoctorCard(
                doctorImagePath: d['image']!,
                rating: d['rating']!,
                doctorName: d['name']!,
                doctorProfession: d['specialty']!,
              ),
            ),
          );
        },
      ),
    );
  }
}
