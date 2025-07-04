// lib/widgets/profile_overview_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/pages/profile/medical_card_page.dart';

class ProfileOverviewBottomSheet extends StatefulWidget {
  const ProfileOverviewBottomSheet({super.key});

  @override
  State<ProfileOverviewBottomSheet> createState() =>
      _ProfileOverviewBottomSheetState();
}

class _ProfileOverviewBottomSheetState
    extends State<ProfileOverviewBottomSheet> {
  Map<String, dynamic>? medicalCard;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final mc = doc.data()?['medicalCard'] as Map<String, dynamic>?;
    if (mounted) {
      setState(() {
        medicalCard = mc;
        isLoading = false;
      });
    }
  }

  Widget _infoTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.subtitle(color: Colors.grey[700]!)),
          const SizedBox(height: 4),
          Text(value ?? '-', style: AppTextStyles.body(color: Colors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Text('Patient Overview', style: AppTextStyles.title1()),
                    const SizedBox(height: 24),

                    _infoTile(
                      'Date of Birth',
                      medicalCard?['birthDate'] != null
                          ? DateFormat(
                            'dd/MM/yyyy',
                          ).format(DateTime.parse(medicalCard!['birthDate']))
                          : null,
                    ),
                    _infoTile('Blood Type', medicalCard?['bloodType']),
                    _infoTile('Allergies', medicalCard?['allergies']),
                    _infoTile('Conditions', medicalCard?['conditions']),
                    _infoTile('Therapy', medicalCard?['therapy']),

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MedicalCardPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple[300],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Edit Profile',
                        style: AppTextStyles.buttons(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
