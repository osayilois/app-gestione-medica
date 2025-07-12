// HOME

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicare_app/pages/auth/login_page.dart';
import 'package:medicare_app/pages/appointments/appointments_list_page.dart';
import 'package:medicare_app/pages/doctor/specialist_page.dart';
import 'package:medicare_app/pages/profile/profile_page.dart';
import 'package:medicare_app/pages/prescriptions/prescriptions_page.dart';
import 'package:medicare_app/pages/profile/medical_card_page.dart';
import 'package:medicare_app/widgets/home_header.dart';
import 'package:medicare_app/widgets/medical_banner.dart';
import 'package:medicare_app/widgets/specialists_section.dart';
import 'package:medicare_app/pages/home/notifications_page.dart';
import 'package:medicare_app/data/mock_doctors.dart';
import 'package:medicare_app/data/specialty_categories.dart';
import 'package:medicare_app/widgets/upcoming_appointments_widget.dart';
import 'package:medicare_app/widgets/top_rated_doctors_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snap.hasData) return const LoginPage();
        return const MainScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _unreadCount = 0;

  static final List<Widget> _pages = <Widget>[
    HomeContent(),
    AppointmentsListPage(),
    PrescriptionsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
            setState(() {
              _unreadCount = snapshot.docs.length;
            });
          });
    }
  }

  void _onTap(int idx) {
    setState(() => _currentIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['Home', 'Appointments', 'Prescriptions', 'Profile'];

    const icons = [
      FontAwesomeIcons.house,
      FontAwesomeIcons.calendarDays,
      FontAwesomeIcons.briefcaseMedical,
      FontAwesomeIcons.userLarge,
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          _currentIndex == 0
              ? AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                title: Text(
                  'Home',
                  style: AppTextStyles.title2(color: Colors.grey[800]!),
                ),
                centerTitle: true,
                actions: [
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          //Icons.notifications,
                          FontAwesomeIcons.bell,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsPage(),
                            ),
                          );
                        },
                      ),
                      if (_unreadCount > 0)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$_unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              )
              : null,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        selectedItemColor: Colors.deepPurple[300],
        unselectedItemColor: Colors.grey[500],
        selectedLabelStyle: AppTextStyles.link(color: Colors.deepPurple[300]!),
        unselectedLabelStyle: AppTextStyles.link(color: Colors.grey[500]!),
        items: List.generate(
          4,
          (i) =>
              BottomNavigationBarItem(icon: Icon(icons[i]), label: labels[i]),
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _searchController = TextEditingController();
  String selectedSpecialty = 'All';
  bool _hasMedical = false;

  @override
  void initState() {
    super.initState();
    _checkMedicalCard();
  }

  Future<void> _checkMedicalCard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final data = doc.data();
    setState(() {
      _hasMedical = data?['medicalCard'] != null;
    });
  }

  void _filterDoctors(String query) {
    SpecialistsSection.of(context)?.filter(query);
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered =
        mockDoctors
            .where((d) => d['name']!.toLowerCase().contains(query))
            .toList();

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1) Header
              HomeHeader(
                getGreeting: getGreeting,
                getUserDisplayName: getUserDisplayName,
              ),
              const SizedBox(height: 25),

              // 2) MedicalBanner
              MedicalBanner(
                hasMedical: _hasMedical,
                onGetStarted: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MedicalCardPage()),
                  ).then((_) => _checkMedicalCard());
                },
              ),
              const SizedBox(height: 25),

              // 3) Search field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: AppTextStyles.subtitle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Search doctors...',
                            hintStyle: AppTextStyles.body(
                              color: Colors.grey.shade600,
                            ),
                            border: InputBorder.none,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // 5) Risultati ricerca o vista standard
              if (query.isNotEmpty) ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final doc = filtered[i];
                    return ListTile(
                      title: Text(
                        doc['name']!,
                        style: AppTextStyles.buttons(color: Colors.black),
                      ),
                      subtitle: Text(
                        doc['specialty']!,
                        style: AppTextStyles.body(color: Colors.black),
                      ),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => SpecialistPage(
                                    specialty: doc['specialty']!,
                                    doctors: mockDoctors,
                                  ),
                            ),
                          ),
                    );
                  },
                ),
              ] else ...[
                // Widget appuntamenti futuri
                const UpcomingAppointmentsWidget(),
                const SizedBox(height: 25),

                SpecialistsSection(
                  categories: specialtyCategories,
                  doctors: mockDoctors,
                  selectedSpecialty: selectedSpecialty,
                  onCategoryTap: (name) {
                    setState(() => selectedSpecialty = name);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => SpecialistPage(
                              specialty: name,
                              doctors: mockDoctors,
                            ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 25),
                TopRatedDoctorsSection(doctors: mockDoctors, threshold: 4.8),
                const SizedBox(height: 25),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String getUserDisplayName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'User';
    return (user.displayName ?? 'User').split(' ').first;
  }
}
