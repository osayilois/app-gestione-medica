import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicare_app/theme/text_styles.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _markAllAsRead() async {
    if (uid == null) return;
    final unread =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .where('read', isEqualTo: false)
            .get();

    for (final doc in unread.docs) {
      await doc.reference.update({'read': true});
    }
  }

  @override
  void initState() {
    super.initState();
    _markAllAsRead();
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'];
    final action = data['action'];
    final itemId = data['itemId'];

    if (type == 'prescription') {
      Navigator.pushNamed(
        context,
        '/prescriptions',
        arguments: {'filter': action, 'focusId': itemId},
      );
    }
    // Puoi gestire altri tipi (es. appointments) qui
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppTextStyles.title2(color: Colors.black),
        ),
        backgroundColor: Colors.deepPurple.shade100,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body:
          uid == null
              ? const Center(child: Text('User not logged in'))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('notifications')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("You don't have any notifications."),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final title = data['title'] ?? 'No title';
                      final body = data['body'] ?? 'No content';
                      final read = data['read'] ?? false;

                      return ListTile(
                        leading: Icon(
                          read
                              ? Icons.notifications_none
                              : Icons.notifications_active,
                          color: read ? Colors.grey : Colors.deepPurple,
                        ),
                        title: Text(title, style: AppTextStyles.subtitle()),
                        subtitle: Text(body, style: AppTextStyles.body()),
                        onTap: () => _handleNotificationTap(data),
                      );
                    },
                  );
                },
              ),
    );
  }
}
