import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/util/doctor_card.dart';
import 'package:medicare_app/pages/medical_card_page.dart';
import 'package:medicare_app/pages/appointment_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare_app/pages/login_page.dart';
import 'package:medicare_app/pages/profile_page.dart';
import 'package:medicare_app/pages/appointments_list_page.dart';

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

  @override
  void initState() {
    super.initState();
    filteredDoctors = doctors;
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
                    'assets/animations/logout.json', // Scegli un'animazione e salvala qui
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

    final fullName = user.displayName ?? 'User';
    final firstName = fullName.split(' ').first;
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
                      Row(
                        children: [
                          GestureDetector(
                            onTapDown: (details) {
                              final tapPosition = details.globalPosition;
                              showMenu<String>(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                  tapPosition.dx,
                                  tapPosition.dy + 10,
                                  tapPosition.dx,
                                  0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: Colors.white,
                                elevation: 8,
                                items: [
                                  PopupMenuItem<String>(
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
                                  PopupMenuItem<String>(
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
                                  PopupMenuItem<String>(
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
                                  PopupMenuItem<String>(
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
                                        builder:
                                            (context) => const ProfilePage(),
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
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.pink[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: Lottie.network(
                            'https://assets2.lottiefiles.com/packages/lf20_tutvdkg0.json',
                          ),
                        ),
                        const SizedBox(width: 20),
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
                              const SizedBox(height: 12),
                              Text(
                                'Fill out your medical card right now',
                                style: AppTextStyles.body(color: Colors.black),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user == null) return;

                                  // Recupera displayName e splitta in nome / cognome
                                  final fullName = user.displayName ?? '';
                                  final parts = fullName.split(' ');
                                  final firstName =
                                      parts.isNotEmpty ? parts.first : '';
                                  final lastName =
                                      parts.length > 1
                                          ? parts.sublist(1).join(' ')
                                          : '';

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MedicalCardPage(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Get Started',
                                      style: AppTextStyles.buttons(
                                        color: Colors.white,
                                      ),
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
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterDoctors,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        hintText: 'Type doctor name',
                        hintStyle: AppTextStyles.body(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: DropdownButton<String>(
                    value: selectedSpecialty,
                    isExpanded: true,
                    style: AppTextStyles.subtitle(color: Colors.black),
                    items:
                        ['All', 'Therapist', 'Dentist', 'Surgeon']
                            .map(
                              (specialty) => DropdownMenuItem<String>(
                                value: specialty,
                                child: Text(specialty),
                              ),
                            )
                            .toList(),
                    onChanged: _onSpecialtyChanged,
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Doctor list',
                        style: AppTextStyles.title2(color: Colors.black),
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
                    itemBuilder: (context, index) {
                      final doctor = filteredDoctors[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AppointmentPage(
                                      doctorName: doctor['name']!,
                                    ),
                              ),
                            );
                          },
                          child: DoctorCard(
                            doctorImagePath: doctor['image']!,
                            rating: doctor['rating']!,
                            doctorName: doctor['name']!,
                            doctorProfession: doctor['specialty']!,
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
