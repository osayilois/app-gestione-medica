import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medicare_app/util/category_card.dart';
import 'package:medicare_app/util/doctor_card.dart';
import 'package:medicare_app/pages/medical_card_page.dart';
import 'package:medicare_app/pages/appointment_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare_app/pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> doctors = [
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

  List<Map<String, String>> filteredDoctors = [];
  TextEditingController _searchController = TextEditingController();
  String selectedSpecialty = 'All';

  @override
  void initState() {
    super.initState();
    filteredDoctors = doctors;
  }

  void _filterDoctors(String query) {
    List<Map<String, String>> results = [];
    if (query.isEmpty && selectedSpecialty == 'All') {
      results = doctors;
    } else {
      results =
          doctors.where((doctor) {
            bool matchesName = doctor['name']!.toLowerCase().contains(
              query.toLowerCase(),
            );
            bool matchesSpecialty =
                selectedSpecialty == 'All' ||
                doctor['specialty'] == selectedSpecialty;
            return matchesName && matchesSpecialty;
          }).toList();
    }
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

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  String getUserDisplayName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      user.reload(); // Forza il ricaricamento dell'utente
      return user.displayName?.split(' ').first ?? 'User';
    } else {
      return 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Greeting and user email or name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello,',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        getUserDisplayName(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),

                  // Profile and logout
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.person),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.logout, color: Colors.red),
                        onPressed: _logout,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 25),

            // "How do you feel?" card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.pink[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      child: Lottie.network(
                        'https://assets2.lottiefiles.com/packages/lf20_tutvdkg0.json',
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How do you feel?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Fill out your medical card right now',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 12),
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
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
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

            SizedBox(height: 25),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                padding: EdgeInsets.all(12),
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
                  ),
                ),
              ),
            ),

            SizedBox(height: 25),

            // Specialty dropdown
            Container(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: DropdownButton<String>(
                  value: selectedSpecialty,
                  items:
                      ['All', 'Therapist', 'Dentist', 'Surgeon'].map((
                        specialty,
                      ) {
                        return DropdownMenuItem<String>(
                          value: specialty,
                          child: Text(specialty),
                        );
                      }).toList(),
                  onChanged: _onSpecialtyChanged,
                  isExpanded: true,
                  hint: Text('Select Specialty'),
                ),
              ),
            ),

            SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Doctor list',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
            ),

            SizedBox(height: 25),

            // Doctor list
            Container(
              height: 250,
              child: Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      filteredDoctors.map((doctor) {
                        return GestureDetector(
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
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
