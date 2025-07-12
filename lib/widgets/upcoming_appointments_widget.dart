// lib/widgets/upcoming_appointments_widget.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';

class UpcomingAppointmentsWidget extends StatefulWidget {
  const UpcomingAppointmentsWidget({Key? key}) : super(key: key);

  @override
  State<UpcomingAppointmentsWidget> createState() =>
      _UpcomingAppointmentsWidgetState();
}

class _UpcomingAppointmentsWidgetState
    extends State<UpcomingAppointmentsWidget> {
  final _pageController = PageController(viewportFraction: 0.8);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('appointments')
              .orderBy('startTime')
              .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final now = DateTime.now();
        final future =
            snap.data!.docs.map((d) => d.data() as Map<String, dynamic>).where((
              d,
            ) {
              final start = DateTime.parse(d['startTime']);
              final isCancelled = (d['status'] as String?) == 'cancelled';
              return start.isAfter(now) && !isCancelled;
            }).toList();

        if (future.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1) animazione Lottie
                SizedBox(
                  height: 120,
                  child: Lottie.asset(
                    'assets/animations/no_appointments.json',
                    repeat: true,
                  ),
                ),
                const SizedBox(height: 16),
                // 2) messaggio
                Text(
                  "You don't have any upcoming appointments",
                  style: AppTextStyles.body(color: Colors.grey[600]!),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Upcoming Appointments',
                  style: AppTextStyles.buttons(color: Colors.deepPurple),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: PageView.builder(
                controller: _pageController,
                itemCount: future.length,
                itemBuilder: (context, index) {
                  final d = future[index];
                  final dt = DateTime.parse(d['startTime']);
                  final date = DateFormat('dd/MM/yyyy').format(dt);
                  final time = DateFormat('HH:mm').format(dt);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      color: Colors.teal.shade100,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundImage:
                              d['doctorImage'] != null
                                  ? AssetImage(d['doctorImage'])
                                  : null,
                          backgroundColor: Colors.grey[200],
                        ),
                        title: Text(
                          d['doctorName'] ?? '',
                          style: AppTextStyles.subtitle(color: Colors.black),
                        ),
                        subtitle: Text(
                          '$date • $time',
                          style: AppTextStyles.body(color: Colors.grey[700]!),
                        ),
                        onTap:
                            () => Navigator.pushNamed(context, '/appointments'),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            SmoothPageIndicator(
              controller: _pageController,
              count: future.length,
              effect: const WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Colors.deepPurple,
              ),
            ),
          ],
        );
      },
    );
  }
}
