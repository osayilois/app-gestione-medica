/* import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/pages/profile/medical_card_page.dart';
import 'package:medicare_app/pages/appointments/appointments_list_page.dart';
import 'package:medicare_app/pages/prescriptions/prescriptions_page.dart';
import 'package:medicare_app/pages/profile/profile_overview_bottom_sheet.dart';
import 'package:medicare_app/widgets/logout_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicare_app/widgets/avatar_picker_bottom_sheet.dart';

final avatars = [
  'assets/avatar/avatar1.png',
  'assets/avatar/avatar2.png',
  'assets/avatar/avatar3.png',
];

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;
  bool _isCameraPressed = false;

  String? avatarUrl;
  String? nome;
  String? cognome;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    final doc = await firestore.collection('users').doc(user!.uid).get();
    final data = doc.data() ?? {};
    setState(() {
      avatarUrl = data['avatarUrl'] ?? _defaultDiceBear();
      final full = user!.displayName ?? '';
      final parts = full.split(' ');
      nome = parts.isNotEmpty ? parts.first : '';
      cognome = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    });
  }

  String _defaultDiceBear() =>
      'https://avatars.dicebear.com/api/avataaars/${user?.uid}.png';

  /* void _openAvatarPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => AvatarPickerBottomSheet(
            avatarList: avatars,
            currentAvatar: avatarUrl,
          ),
    );
  } */

  void _openAvatarPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => AvatarPickerBottomSheet(
            avatarList: avatars,
            currentAvatar: avatarUrl,
          ),
    ).then((_) {
      // appena chiusa la bottom sheet, ricarico avatarUrl da Firestore
      _loadUserData();
    });
  }

  void _openOverview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileOverviewBottomSheet(),
    );
  }

  void _openAppointments() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AppointmentsListPage()),
  );
  void _openPrescriptions() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const PrescriptionsPage()),
  );
  void _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const LogoutDialog(),
    );
    if (result == true) {
      await FirebaseAuth.instance.signOut();
      // TODO: navigate to login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color(0xFFF3F2F8),
      backgroundColor: Colors.deepPurple.shade300,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          const SizedBox(height: 16), // Sposta leggermente giù la sezione lilla
          // Header section
          Container(
            width: double.infinity,

            //color: const Color(0xFFF3F2F8),
            color: Colors.deepPurple.shade300,
            padding: const EdgeInsets.only(top: 40, bottom: 20),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                      backgroundColor: Colors.grey.shade200,
                      child:
                          avatarUrl == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                    ),
                    Positioned(
                      child: GestureDetector(
                        onTapDown:
                            (_) => setState(() => _isCameraPressed = true),
                        onTapUp: (_) {
                          setState(() => _isCameraPressed = false);
                          _openAvatarPicker();
                        },
                        onTapCancel:
                            () => setState(() => _isCameraPressed = false),
                        child: AnimatedScale(
                          scale: _isCameraPressed ? 0.85 : 1.0,
                          duration: const Duration(milliseconds: 120),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.deepPurple.shade300,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${nome ?? ''} ${cognome ?? ''}',
                  style: AppTextStyles.title1(color: Colors.white),
                ),
                const SizedBox(height: 20),
                // Info columns
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoColumn(
                        icon: FontAwesomeIcons.heartPulse,
                        title: 'Heart rate',
                        info: '210 bpm',
                      ),
                      _InfoColumn(
                        icon: FontAwesomeIcons.fireFlameCurved,
                        title: 'Calories',
                        info: '576 Cal',
                      ),
                      _InfoColumn(
                        icon: FontAwesomeIcons.weightScale,
                        title: 'Weight',
                        info: '70 kg',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom sheet
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  _ProfileCardItem(
                    icon: Icons.person,
                    text: 'Overview',
                    color: Colors.deepPurple.shade300,
                    onTap: _openOverview,
                  ),
                  const Divider(color: Color(0xFFE0E0E0)),
                  _ProfileCardItem(
                    icon: Icons.calendar_today,
                    text: 'Appointments',
                    color: Colors.deepPurple.shade300,
                    onTap: _openAppointments,
                  ),
                  const Divider(color: Color(0xFFE0E0E0)),
                  _ProfileCardItem(
                    icon: Icons.receipt_long,
                    text: 'Prescriptions',
                    color: Colors.deepPurple.shade300,
                    onTap: _openPrescriptions,
                  ),
                  const Divider(color: Color(0xFFE0E0E0)),
                  _ProfileCardItem(
                    icon: Icons.logout,
                    text: 'Logout',
                    color: Colors.redAccent,
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String title;
  final String info;

  const _InfoColumn({
    Key? key,
    required this.icon,
    required this.title,
    required this.info,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.white),
        const SizedBox(height: 4),
        Text(title, style: AppTextStyles.body(color: Colors.white)),
        Text(info, style: AppTextStyles.title2(color: Colors.white)),
      ],
    );
  }
}

class _ProfileCardItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _ProfileCardItem({
    Key? key,
    required this.icon,
    required this.text,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Text(text, style: AppTextStyles.body(color: Colors.black87)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
 */

// lib/pages/profile/profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/pages/appointments/appointments_list_page.dart';
import 'package:medicare_app/pages/prescriptions/prescriptions_page.dart';
import 'package:medicare_app/pages/profile/medical_card_page.dart';
import 'package:medicare_app/widgets/logout_dialog.dart';
import 'package:medicare_app/widgets/avatar_picker_bottom_sheet.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicare_app/pages/profile/profile_overview_bottom_sheet.dart';

const avatars = [
  'assets/avatar/avatar1.png',
  'assets/avatar/avatar2.png',
  'assets/avatar/avatar3.png',
  'assets/avatar/avatar4.png',
  'assets/avatar/avatar5.png',
  'assets/avatar/avatar6.png',
];

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  String? avatarUrl;
  String? nome;
  String? cognome;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .listen((doc) {
          final data = doc.data() ?? {};
          setState(() {
            avatarUrl = data['avatarUrl'] as String?;
            final full = user!.displayName ?? '';
            final parts = full.split(' ');
            nome = parts.isNotEmpty ? parts.first : '';
            cognome = parts.length > 1 ? parts.sublist(1).join(' ') : '';
          });
        });
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    final doc = await firestore.collection('users').doc(user!.uid).get();
    final data = doc.data() ?? {};
    setState(() {
      avatarUrl = data['avatarUrl'] as String?;
      final full = user!.displayName ?? '';
      final parts = full.split(' ');
      nome = parts.isNotEmpty ? parts.first : '';
      cognome = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    });
  }

  Future<void> _openAvatarPicker() async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => AvatarPickerBottomSheet(
            avatarList: avatars,
            currentAvatar: avatarUrl,
          ),
    );
    if (selected != null && selected != avatarUrl) {
      await firestore.collection('users').doc(user!.uid).set({
        'avatarUrl': selected,
      }, SetOptions(merge: true));
      _loadUserData();
    }
  }

  void _openOverview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileOverviewBottomSheet(),
    );
  }

  void _openAppointments() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AppointmentsListPage()),
    );
  }

  void _openPrescriptions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrescriptionsPage()),
    );
  }

  void _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const LogoutDialog(),
    );
    if (result == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade300,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            color: Colors.deepPurple.shade300,
            padding: const EdgeInsets.only(top: 40, bottom: 20),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          avatarUrl != null
                              ? (avatarUrl!.startsWith('http')
                                  ? NetworkImage(avatarUrl!)
                                  : AssetImage(avatarUrl!) as ImageProvider)
                              : null,
                      backgroundColor: Colors.grey.shade200,
                      child:
                          avatarUrl == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                    ),
                    _CameraPickerIcon(onTap: _openAvatarPicker),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '$nome $cognome',
                  style: AppTextStyles.title1(color: Colors.white),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoColumn(
                        icon: FontAwesomeIcons.heartPulse,
                        title: 'Heart rate',
                        info: '210 bpm',
                      ),
                      _InfoColumn(
                        icon: FontAwesomeIcons.fireFlameCurved,
                        title: 'Calories',
                        info: '576 Cal',
                      ),
                      _InfoColumn(
                        icon: FontAwesomeIcons.weightScale,
                        title: 'Weight',
                        info: '70 kg',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  _ProfileCardItem(
                    icon: Icons.person,
                    text: 'Overview',
                    color: Colors.deepPurple.shade300,
                    onTap: _openOverview,
                  ),
                  const Divider(color: Color(0xFFE0E0E0)),
                  _ProfileCardItem(
                    icon: Icons.calendar_today,
                    text: 'Appointments',
                    color: Colors.deepPurple.shade300,
                    onTap: _openAppointments,
                  ),
                  const Divider(color: Color(0xFFE0E0E0)),
                  _ProfileCardItem(
                    icon: Icons.receipt_long,
                    text: 'Prescriptions',
                    color: Colors.deepPurple.shade300,
                    onTap: _openPrescriptions,
                  ),
                  const Divider(color: Color(0xFFE0E0E0)),
                  _ProfileCardItem(
                    icon: Icons.logout,
                    text: 'Logout',
                    color: Colors.redAccent,
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraPickerIcon extends StatefulWidget {
  final VoidCallback onTap;
  const _CameraPickerIcon({required this.onTap});
  @override
  State<_CameraPickerIcon> createState() => _CameraPickerIconState();
}

class _CameraPickerIconState extends State<_CameraPickerIcon> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.8 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.camera_alt,
            size: 20,
            color: Colors.deepPurple.shade300,
          ),
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String title;
  final String info;
  const _InfoColumn({
    required this.icon,
    required this.title,
    required this.info,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.white),
        const SizedBox(height: 4),
        Text(title, style: AppTextStyles.body(color: Colors.white)),
        Text(info, style: AppTextStyles.title2(color: Colors.white)),
      ],
    );
  }
}

class _ProfileCardItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;
  const _ProfileCardItem({
    required this.icon,
    required this.text,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Text(text, style: AppTextStyles.body(color: Colors.black87)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
