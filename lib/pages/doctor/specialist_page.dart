// lib/pages/specialist_page.dart

import 'package:flutter/material.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/util/doctor_card.dart';
import 'package:medicare_app/pages/doctor/doctor_profile_page.dart';

enum SortOrder { az, za }

class SpecialistPage extends StatefulWidget {
  final String specialty;
  final List<Map<String, String>> doctors;

  const SpecialistPage({
    super.key,
    required this.specialty,
    required this.doctors,
  });

  @override
  State<SpecialistPage> createState() => _SpecialistPageState();
}

class _SpecialistPageState extends State<SpecialistPage> {
  SortOrder _sortOrder = SortOrder.az;

  @override
  Widget build(BuildContext context) {
    // Filtra in base alla specialty
    List<Map<String, String>> filtered =
        widget.specialty == 'All'
            ? List<Map<String, String>>.from(widget.doctors)
            : widget.doctors
                .where((d) => d['specialty'] == widget.specialty)
                .toList();

    // Ordina in base allo _sortOrder
    filtered.sort((a, b) {
      final nameA = (a['name'] ?? '').toLowerCase();
      final nameB = (b['name'] ?? '').toLowerCase();
      if (_sortOrder == SortOrder.az) {
        return nameA.compareTo(nameB);
      } else {
        return nameB.compareTo(nameA);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.specialty == 'All' ? 'All Doctors' : widget.specialty,
          style: AppTextStyles.title2(color: Colors.grey.shade800),
        ),
        actions: [
          PopupMenuButton<SortOrder>(
            icon: Icon(Icons.sort, color: Colors.grey[800]),
            onSelected: (order) {
              setState(() {
                _sortOrder = order;
              });
            },
            itemBuilder:
                (ctx) => [
                  CheckedPopupMenuItem(
                    value: SortOrder.az,
                    checked: _sortOrder == SortOrder.az,
                    child: Text(
                      'Ordina A-Z',
                      style: AppTextStyles.body(color: Colors.black),
                    ),
                  ),
                  CheckedPopupMenuItem(
                    value: SortOrder.za,
                    checked: _sortOrder == SortOrder.za,
                    child: Text(
                      'Ordina Z-A',
                      style: AppTextStyles.body(color: Colors.black),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) {
          final d = filtered[i];
          // Estrai in modo null-safe, fallback '' se mancante:
          final name = d['name'] ?? '';
          final specialty = d['specialty'] ?? '';
          final imagePath = d['image'] ?? '';
          final rating = d['rating'] ?? '';
          final bio = d['bio'] ?? '';
          final address = d['address'] ?? '';
          final phone = d['phone'] ?? '';
          final email = d['email'] ?? '';
          final hours = d['hours'] ?? '';

          // Se mancano i campi fondamentali, salta (o potresti mostrare placeholder)
          if (name.isEmpty ||
              specialty.isEmpty ||
              imagePath.isEmpty ||
              rating.isEmpty) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => DoctorProfilePage(
                          name: name,
                          specialty: specialty,
                          imagePath: imagePath,
                          rating: rating,
                          bio: bio,
                          address: address,
                          phone: phone,
                          email: email,
                          hours: hours,
                        ),
                  ),
                );
              },
              child: DoctorCard(
                doctorImagePath: imagePath,
                rating: rating,
                doctorName: name,
                doctorProfession: specialty,
              ),
            ),
          );
        },
      ),
    );
  }
}
