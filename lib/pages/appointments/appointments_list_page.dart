import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/pages/appointments/appointment_page.dart';

/// Mostra gli appuntamenti divisi per stato con grafica in linea alle prescrizioni
class AppointmentsListPage extends StatefulWidget {
  const AppointmentsListPage({Key? key}) : super(key: key);

  @override
  State<AppointmentsListPage> createState() => _AppointmentsListPageState();
}

enum AppointmentStatus { upcoming, completed, cancelled }

class _AppointmentsListPageState extends State<AppointmentsListPage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  AppointmentStatus _currentStatus = AppointmentStatus.upcoming;

  Stream<QuerySnapshot> get _stream =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('appointments')
          .orderBy('startTime', descending: true)
          .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: List.generate(AppointmentStatus.values.length, (i) {
                  final status = AppointmentStatus.values[i];
                  final isSel = status == _currentStatus;
                  final labels = ['Upcoming', 'Completed', 'Cancelled'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentStatus = status),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color:
                              isSel
                                  ? Colors.deepPurple[300]
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            labels[i],
                            style: AppTextStyles.body(
                              color: isSel ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _stream,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data?.docs ?? [];
                final now = DateTime.now();
                final items =
                    docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final start = DateTime.parse(data['startTime']);
                      final cancelled = data['status'] == 'cancelled';
                      switch (_currentStatus) {
                        case AppointmentStatus.upcoming:
                          return !cancelled && start.isAfter(now);
                        case AppointmentStatus.completed:
                          return !cancelled && start.isBefore(now);
                        case AppointmentStatus.cancelled:
                          return cancelled;
                      }
                    }).toList();
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'No appointments',
                      style: AppTextStyles.body(color: Colors.black),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final doc = items[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final start = DateTime.parse(data['startTime']);
                    final doctor = data['doctorName'] as String? ?? '—';
                    final img = data['doctorImage'] as String?;
                    final isUpcoming =
                        _currentStatus == AppointmentStatus.upcoming;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (img != null)
                                  CircleAvatar(
                                    backgroundImage: AssetImage(img),
                                    radius: 24,
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doctor,
                                        style: AppTextStyles.title2(
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        data['doctorSpecialty'] as String? ??
                                            '',
                                        style: AppTextStyles.body(
                                          color: Colors.grey[700]!,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(start),
                                  style: AppTextStyles.body(
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('HH:mm').format(start),
                                  style: AppTextStyles.body(
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color:
                                        isUpcoming
                                            ? Colors.orange
                                            : (_currentStatus ==
                                                    AppointmentStatus.completed
                                                ? Colors.green
                                                : Colors.red),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  {
                                    AppointmentStatus.upcoming: 'Upcoming',
                                    AppointmentStatus.completed: 'Completed',
                                    AppointmentStatus.cancelled: 'Cancelled',
                                  }[_currentStatus]!,
                                  style: AppTextStyles.body(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            if (isUpcoming) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder:
                                              (ctx) => AlertDialog(
                                                title: Text(
                                                  'Confirm Cancellation',
                                                  style: AppTextStyles.title2(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                content: Text(
                                                  'Are you sure you want to cancel this appointment?',
                                                  style: AppTextStyles.body(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          ctx,
                                                          false,
                                                        ),
                                                    child: Text(
                                                      'No',
                                                      style:
                                                          AppTextStyles.buttons(
                                                            color:
                                                                Colors
                                                                    .deepPurple,
                                                          ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          ctx,
                                                          true,
                                                        ),
                                                    child: Text(
                                                      "Yes, I'm sure",
                                                      style:
                                                          AppTextStyles.buttons(
                                                            color:
                                                                Colors
                                                                    .deepPurple,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );
                                        if (confirm == true) {
                                          await doc.reference.update({
                                            'status': 'cancelled',
                                          });
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: AppTextStyles.buttons(
                                          color: Colors.black,
                                        ),
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
                                                  doctorName:
                                                      data['doctorName'],
                                                  doctorSpecialty:
                                                      data['doctorSpecialty'],
                                                  doctorImagePath:
                                                      data['doctorImage'],
                                                  appointmentId: doc.id,
                                                ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.deepPurple.shade300,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Reschedule',
                                        style: AppTextStyles.buttons(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
