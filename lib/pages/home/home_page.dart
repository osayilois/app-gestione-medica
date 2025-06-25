// lib/pages/home_page.dart
// Refactoring: estratte sezioni in widget separati per migliorare navigazione e manutenzione.

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
import 'package:medicare_app/widgets/search_bar.dart';
import 'package:medicare_app/widgets/specialists_section.dart';
import 'package:medicare_app/widgets/logout_dialog.dart';
import 'package:medicare_app/data/mock_doctors.dart';
import 'package:medicare_app/data/specialty_categories.dart';

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

  static const List<Widget> _pages = <Widget>[
    HomeContent(),
    AppointmentsListPage(),
    PrescriptionsPage(),
    ProfilePage(),
  ];

  void _onTap(int idx) {
    setState(() => _currentIndex = idx);
  }

  Future<void> _confirmLogout() async {
    final should = await showDialog<bool>(
      context: context,
      builder: (_) => LogoutDialog(),
    );
    if (should == true) await FirebaseAuth.instance.signOut();
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          labels[_currentIndex],
          style: AppTextStyles.title2(color: Colors.grey[800]!),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        showSelectedLabels: true,
        selectedItemColor: Colors.deepPurple[300],
        unselectedItemColor: Colors.grey[500],
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
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            children: [
              // Widget per header con saluto
              HomeHeader(
                getGreeting: getGreeting,
                getUserDisplayName: getUserDisplayName,
              ),
              const SizedBox(height: 25),
              // Widget per banner medical card
              MedicalBanner(
                hasMedical: _hasMedical,
                onGetStarted: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MedicalCardPage()),
                  );
                  await _checkMedicalCard();
                },
              ),
              const SizedBox(height: 25),
              // Widget per search bar
              DoctorSearchBar(
                controller: _searchController,
                onSearch: _filterDoctors,
              ),
              const SizedBox(height: 25),
              // Widget per sezione specialists
              SpecialistsSection(
                categories: categories,
                doctors: doctors,
                selectedSpecialty: selectedSpecialty,
                onCategoryTap: (name) {
                  setState(() => selectedSpecialty = name);
                  _filterDoctors(_searchController.text);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              SpecialistPage(specialty: name, doctors: doctors),
                    ),
                  );
                },
              ),
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

  List<Map<String, String>> get doctors => mockDoctors;
  List<Map<String, dynamic>> get categories => specialtyCategories;
}
