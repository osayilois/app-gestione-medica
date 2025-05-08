import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medicare_app/util/doctor_card.dart';
import 'package:medicare_app/pages/medical_card_page.dart';
import 'package:medicare_app/pages/appointment_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare_app/pages/login_page.dart';

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
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
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
                          const Text(
                            'Hello,',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            getUserDisplayName(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.red),
                            onPressed: _confirmLogout,
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
                              const Text(
                                'How do you feel?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Fill out your medical card right now',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MedicalCardPage(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Get Started',
                                      style: TextStyle(color: Colors.white),
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
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        hintText: 'Type doctor name',
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Doctor list',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
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
