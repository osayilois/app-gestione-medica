import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare_app/theme/text_styles.dart';

class AdminPrescriptionPage extends StatefulWidget {
  const AdminPrescriptionPage({super.key});

  @override
  State<AdminPrescriptionPage> createState() => _AdminPrescriptionPageState();
}

class _AdminPrescriptionPageState extends State<AdminPrescriptionPage> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Prescriptions',
          style: AppTextStyles.title1(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple.shade200,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collectionGroup('prescriptions').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Nessuna richiesta disponibile.',
                style: AppTextStyles.body(),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docRef = docs[index].reference;
              final status = data['status'];
              final patientId = data['patientId'];
              final name = data['name'];
              final type = data['type'];
              final doctorName = data['doctorName'] ?? 'N/A';
              final timestamp = (data['timestamp'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type: $type', style: AppTextStyles.title2()),
                      const SizedBox(height: 4),
                      Text('Name: $name', style: AppTextStyles.body()),
                      const SizedBox(height: 4),
                      Text(
                        'Patient ID: $patientId',
                        style: AppTextStyles.body().copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: $status',
                        style: AppTextStyles.body().copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              status == 'approved'
                                  ? Colors.green
                                  : status == 'rejected'
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Medical Practitioner: $doctorName',
                        style: AppTextStyles.body().copyWith(fontSize: 12),
                      ),
                      Text(
                        'Date: ${timestamp.toString().substring(0, 16)}',
                        style: AppTextStyles.body().copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      if (status == 'pending')
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check, size: 18),
                              label: Text(
                                'Approve',
                                style: AppTextStyles.buttons(
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              onPressed:
                                  () => _updateStatus(docRef, 'approved'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.close, size: 18),
                              label: Text(
                                'Decline',
                                style: AppTextStyles.buttons(
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed:
                                  () => _updateStatus(docRef, 'declined'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(DocumentReference docRef, String newStatus) async {
    await docRef.update({'status': newStatus});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Request $newStatus')));
  }
}
