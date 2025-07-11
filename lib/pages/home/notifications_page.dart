// lib/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare_app/theme/text_styles.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final coll = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: coll.snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Text("No notifications", style: AppTextStyles.body()),
            );
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final text = data['text'] as String? ?? '';
              final read = data['read'] as bool? ?? false;
              final ts = (data['timestamp'] as Timestamp).toDate();
              return ListTile(
                tileColor: read ? null : Colors.deepPurple.shade50,
                title: Text(text, style: AppTextStyles.body()),
                subtitle: Text(
                  '${ts.day}/${ts.month}/${ts.year} ${ts.hour}:${ts.minute.toString().padLeft(2, '0')}',
                ),
                onTap: () {
                  docs[i].reference.update({'read': true});
                },
              );
            },
          );
        },
      ),
    );
  }
}
