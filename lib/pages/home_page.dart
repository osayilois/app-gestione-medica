// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/util/doctor_card.dart';
import 'package:medicare_app/util/category_card.dart';
import 'package:medicare_app/pages/medical_card_page.dart';
import 'package:medicare_app/pages/appointment_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare_app/pages/login_page.dart';
import 'package:medicare_app/pages/profile_page.dart';
import 'package:medicare_app/pages/appointments_list_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginPage();
        }

        return const _HomeContent();
      },
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent({super.key});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final List<Map<String, String>> doctors = [
    {
      'name': 'Dr. Amanda Chavez',
      'specialty': 'Therapist',
      'image': 'lib/images/humberto-chavez-FVh_yqLR9eA-unsplash.jpg',
      'rating': '4.9',
    },
    {
      'name': 'Dr. Jeremy Alford',
      'specialty': 'Dentist',
      'image': 'lib/images/jeremy-alford-O13B7suRG4A-unsplash.jpg',
      'rating': '4.6',
    },
    {
      'name': 'Dr. Usman Yousaf',
      'specialty': 'Surgeon',
      'image': 'lib/images/usman-yousaf-pTrhfmj2jDA-unsplash.jpg',
      'rating': '5.0',
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String selectedSpecialty = 'All';
  List<Map<String, String>> filteredDoctors = [];

  // Categorie
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Cardiologist',
      'iconData': MdiIcons.heartPulse,
      'color': Colors.red.shade300,
    },
    {
      'name': 'Dentist',
      'iconData': MdiIcons.tooth,
      'color': Colors.blue.shade300,
    },
    {
      'name': 'Eye Specialist',
      'iconData': MdiIcons.eye,
      'color': Colors.orange.shade300,
    },
    {
      'name': 'Orthopaedic',
      'iconData': Icons.wheelchair_pickup_sharp,
      'color': Colors.teal.shade300,
    },
    {
      'name': 'Paediatrician',
      'iconData': MdiIcons.baby,
      'color': Colors.green.shade300,
    },
    {
      'name': 'Neurologist',
      'iconData': MdiIcons.brain,
      'color': Colors.purple.shade300,
    },
    {
      'name': 'Psychiatrist',
      'iconData': MdiIcons.emoticonHappy,
      'color': Colors.pink.shade300,
    },
    {
      'name': 'Dermatologist',
      'iconData': MdiIcons.faceManShimmer,
      'color': Colors.brown.shade300,
    },
  ];

  bool _hasMedical = false; // se ha già compilato medicalCard
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    filteredDoctors = doctors;
    _checkMedicalCard();
  }

  Future<void> _checkMedicalCard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();
    setState(() {
      _hasMedical = data?['medicalCard'] != null;
    });
  }

  void _filterDoctors(String query) {
    final results =
        doctors.where((doctor) {
          final matchesName = doctor['name']!.toLowerCase().contains(
            query.toLowerCase(),
          );
          final matchesSpecialty =
              selectedSpecialty == 'All' ||
              doctor['specialty'] == selectedSpecialty;
          return matchesName && matchesSpecialty;
        }).toList();

    setState(() {
      filteredDoctors = results;
    });
  }

  void _onSpecialtyChanged(String? newSpecialty) {
    setState(() {
      selectedSpecialty = newSpecialty ?? 'All';
    });
    _filterDoctors(_searchController.text);
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ANIMAZIONE LOTTIE
                SizedBox(
                  height: 120,
                  child: Lottie.asset(
                    'assets/animations/logout.json',
                    repeat: false,
                  ),
                ),
                const SizedBox(height: 12),
                // MESSAGGIO CENTRATO
                Text(
                  'Are you sure you want to log out?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title2(color: Colors.black),
                ),
                const SizedBox(height: 20),
                // BOTTONE LOGOUT
                SizedBox(
                  width: 150,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.deepPurple[300],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: AppTextStyles.buttons(),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Logout'),
                  ),
                ),
                const SizedBox(height: 8),
                // BOTTONE CANCEL SENZA RIQUADRO
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.buttons(
                      color: Colors.deepPurple[300]!,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  String getUserDisplayName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'User';
    final firstName = (user.displayName ?? 'User').split(' ').first;
    return firstName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello,',
                            style: AppTextStyles.title2(color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            getUserDisplayName(),
                            style: AppTextStyles.title1(color: Colors.black),
                          ),
                        ],
                      ),
                      // MENU -> Profile, Prescriptions, Appointments, Logout
                      GestureDetector(
                        onTapDown: (details) {
                          final pos = details.globalPosition;
                          showMenu<String>(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              pos.dx,
                              pos.dy + 10,
                              pos.dx,
                              0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Colors.white,
                            elevation: 8,
                            items: [
                              PopupMenuItem(
                                value: 'profile',
                                child: ListTile(
                                  leading: const Icon(Icons.person_outline),
                                  title: Text(
                                    'Profile',
                                    style: AppTextStyles.subtitle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'prescriptions',
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.medication_outlined,
                                  ),
                                  title: Text(
                                    'Prescriptions',
                                    style: AppTextStyles.subtitle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'appointments',
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.event_note_outlined,
                                  ),
                                  title: Text(
                                    'Appointments',
                                    style: AppTextStyles.subtitle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'logout',
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.logout,
                                    color: Colors.red,
                                  ),
                                  title: Text(
                                    'Logout',
                                    style: AppTextStyles.subtitle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ).then((value) {
                            switch (value) {
                              case 'profile':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfilePage(),
                                  ),
                                );
                                break;
                              case 'prescriptions':
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Sezione "Ricette" in arrivo!',
                                    ),
                                  ),
                                );
                                break;
                              case 'appointments':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => const AppointmentsListPage(),
                                  ),
                                );
                                break;
                              case 'logout':
                                _confirmLogout();
                                break;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple[100],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.person),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // BANNER o TITOLO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_hasMedical) ...[
                        // 1) banner "Get Started" (solo al primo login)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.pink[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 80,
                                width: 80,
                                child: Lottie.network(
                                  'https://assets2.lottiefiles.com/packages/lf20_tutvdkg0.json',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'How do you feel?',
                                      style: AppTextStyles.subtitle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Fill out your medical card right now',
                                      style: AppTextStyles.body(
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => const MedicalCardPage(),
                                          ),
                                        ).then((_) => _checkMedicalCard());
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple[300],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          'Get Started',
                                          style: AppTextStyles.buttons(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // 2) titolo sotto il banner
                        Text(
                          'Find your doctor',
                          style: AppTextStyles.bigtitle(color: Colors.black),
                        ),
                      ] else ...[
                        // utente già compilato -> titolo in alto
                        Text(
                          'Find your doctor',
                          style: AppTextStyles.bigtitle(color: Colors.black),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // 3) search bar personalizzata (leggermente più alta)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // grigio chiaro
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: _filterDoctors,
                                decoration: InputDecoration(
                                  hintText: 'Search doctor',
                                  hintStyle: AppTextStyles.body(
                                    color: Colors.grey[600]!,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            // il bottone rotondo lilla
                            Material(
                              color: Colors.deepPurple[300], // tema lilla
                              shape: const CircleBorder(),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                                onPressed:
                                    () =>
                                        _filterDoctors(_searchController.text),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // mini TITOLO "Specialists"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Specialists',
                      style: AppTextStyles.title2(color: Colors.deepPurple),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // CATEGORIE SCORREVOLI ORIZZONTALI (4x4 più compatte)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return CategoryCard(
                        iconData: cat['iconData'],
                        categoryName: cat['name'],
                        backgroundColor: cat['color'],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // SPECIALTY DROPDOWN
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: DropdownButton<String>(
                    value: selectedSpecialty,
                    isExpanded: true,
                    style: AppTextStyles.subtitle(color: Colors.black),
                    items:
                        ['All', 'Therapist', 'Dentist', 'Surgeon']
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                    onChanged: _onSpecialtyChanged,
                  ),
                ),

                const SizedBox(height: 25),

                // DOCTOR LIST
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Doctor list',
                        style: AppTextStyles.title2(color: Colors.deepPurple),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredDoctors.length,
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    itemBuilder: (context, i) {
                      final doc = filteredDoctors[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => AppointmentPage(
                                      doctorName: doc['name']!,
                                    ),
                              ),
                            );
                          },
                          child: DoctorCard(
                            doctorImagePath: doc['image']!,
                            rating: doc['rating']!,
                            doctorName: doc['name']!,
                            doctorProfession: doc['specialty']!,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
