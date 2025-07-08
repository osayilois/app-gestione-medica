// lib/widgets/avatar_picker_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Widget per la selezione dell'avatar
/// Mostra in verticale una griglia 2xN degli avatar in assets
class AvatarPickerBottomSheet extends StatelessWidget {
  /// Lista dei percorsi degli avatar in assets
  final List<String> avatarList;
  final String? currentAvatar;

  const AvatarPickerBottomSheet({
    Key? key,
    required this.avatarList,
    this.currentAvatar,
  }) : super(key: key);

  Future<void> _selectAvatar(BuildContext context, String? url) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'avatarUrl': url,
      }, SetOptions(merge: true));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const Text(
            'Choose your avatar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: avatarList.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              // Prima cella: avatar vuoto
              if (index == 0) {
                return GestureDetector(
                  onTap: () => _selectAvatar(context, null),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(
                      Icons.person_outline,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                );
              }
              final assetPath = avatarList[index - 1];
              final isSelected = assetPath == currentAvatar;
              return GestureDetector(
                onTap: () => _selectAvatar(context, assetPath),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(assetPath),
                      backgroundColor: Colors.grey[200],
                    ),
                    if (isSelected)
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black26,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
