// lib/pages/appointments_list_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AppointmentsListPage extends StatelessWidget {
  const AppointmentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final coll = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .orderBy('startTime', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('I tuoi appuntamenti')),
      body: StreamBuilder<QuerySnapshot>(
        stream: coll.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Nessun appuntamento prenotato.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data()! as Map<String, dynamic>;
              final start = DateTime.parse(data['startTime']);
              final end = DateTime.parse(data['endTime']);
              return ListTile(
                leading: const Icon(Icons.event_note, color: Colors.deepPurple),
                title: Text(data['doctorName'] ?? '—'),
                subtitle: Text(
                  '${DateFormat('dd/MM/yyyy HH:mm').format(start)}'
                  ' – ${DateFormat('HH:mm').format(end)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Rimuovi dal DB
                    docs[i].reference.delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
