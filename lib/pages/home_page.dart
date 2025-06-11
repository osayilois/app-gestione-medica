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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicare_app/pages/specialist_page.dart';
import 'package:medicare_app/pages/prescriptions_page.dart';

String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 18) return 'Good afternoon';
  return 'Good evening';
}

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

  // Qui gli “stack” delle 4 pagine
  static const List<Widget> _pages = <Widget>[
    _HomeContent(),
    AppointmentsListPage(),
    // placeholder per “Prescriptions” finché non la crei
    PrescriptionsPage(),
    ProfilePage(),
  ];

  void _onTap(int idx) {
    setState(() => _currentIndex = idx);
  }

  Future<void> _confirmLogout() async {
    final should = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 120,
                  child: Lottie.asset(
                    'assets/animations/logout.json',
                    repeat: false,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to log out?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title2(color: Colors.black),
                ),
                const SizedBox(height: 20),
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
    if (should == true) await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    // Titoli e colori per la BottomBar
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
        items: List.generate(4, (i) {
          return BottomNavigationBarItem(
            icon: Icon(icons[i]),
            label: labels[i],
          );
        }),
      ),
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
      'name': 'Dr. Amanda Chaves',
      'specialty': 'Therapist',
      'image': 'lib/images/humberto-chavez-FVh_yqLR9eA-unsplash.jpg',
      'rating': '4.9',
      'bio': 'Dr. Amanda Chaves is a Therapist with years of experience.',
      'address': 'Via Vasca Navale, 79',
      'phone': '+39031234567',
      'email': 'amanda.chavez@clinic.com',
      'hours': 'Mon-Fri 9:00-17:00',
    },
    {
      'name': 'Dr. Michael Uzor',
      'specialty': 'Dentist',
      'image': 'lib/images/dr_mike.jpg',
      'rating': '4.6',
      'bio': 'Dr. Michael Uzor is a Dentist with years of experience.',
      'address': 'Via Vasca Navale, 79',
      'phone': '+39041234567',
      'email': 'michael.uzor@clinic.com',
      'hours': 'Wed-Sat 9:00-18:00',
    },
    {
      'name': 'Dr. Usman Yousaf',
      'specialty': ' Plastic Surgeon',
      'image': 'lib/images/usman-yousaf-pTrhfmj2jDA-unsplash.jpg',
      'rating': '5.0',
      'bio': 'Dr. Usman Yousaf is a Plastic Surgeon with years of experience.',
      'address': 'Via Vasca Navale, 79',
      'phone': '+39051234567',
      'email': 'usman.yousaf@clinic.com',
      'hours': 'Mon-Sat 9:00-18:30',
    },
    {
      'name': 'Dr. Rosa Fernandez',
      'specialty': 'Cardiologist',
      'image': 'lib/images/dr_rosa.jpg',
      'rating': '4.8',
      'bio': 'Dr. Rosa Fernandez is a Cardiologist with years of experience.',
      'address': 'Via Vasca Navale, 79',
      'phone': '+39061234567',
      'email': 'rosa.ferna@clinic.com',
      'hours': 'Mon-Fri 10:00-19:00',
    },
    {
      'name': 'Dr. Elena Petrova',
      'specialty': 'Paediatrician',
      'image': 'lib/images/dr_elena.jpg',
      'rating': '4.7',
      'bio': 'Dr. Elena Petrova is a Paediatrician with years of experience.',
      'address': 'Via Vasca Navale, 79',
      'phone': '+39071234567',
      'email': 'elena.petrova@clinic.com',
      'hours': 'Tue-Fri 10:00-17:00',
    },
    {
      'name': 'Dr. Michael Austin',
      'specialty': 'Dermatologist',
      'image': 'lib/images/dr_austin.jpg',
      'rating': '4.5',
      'bio': 'Dr. Michael Austin is a Dermatologist with years of experience.',
      'address': 'Via Vasca Navale, 79',
      'phone': '+39081234567',
      'email': 'mike.austin@clinic.com',
      'hours': 'Mon-Fri 9:00-18:30',
    },
    {
      'name': 'Dr. Victor Singh',
      'specialty': 'Gynecologist',
      'image': 'lib/images/dr_victor.jpg',
      'rating': '4.4',
      'bio': 'Dr. Victor Singh is a Gynecologist with years of experience.',
      'address': 'Via Vasca Navale, 79',
      'phone': '+39091234567',
      'email': 'vic.singh@clinic.com',
      'hours': 'Tue-Fri 10:00-18:00',
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String selectedSpecialty = 'All';
  List<Map<String, String>> filteredDoctors = [];

  // Categorie con icone e colori
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'All',
      'iconData': FontAwesomeIcons.borderAll,
      'color': Colors.deepPurple.shade300,
    },
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
      'iconData': FontAwesomeIcons.solidEye,
      'color': Colors.orange.shade300,
    },
    {
      'name': 'Orthopaedic',
      'iconData': Icons.wheelchair_pickup_sharp,
      'color': Colors.teal.shade300,
    },
    {
      'name': 'Paediatrician',
      'iconData': FontAwesomeIcons.baby,
      'color': Colors.green.shade300,
    },
    {
      'name': 'Surgeon',
      'iconData': FontAwesomeIcons.stethoscope,
      'color': Colors.purple.shade300,
    },
    {
      'name': 'Dermatologist',
      'iconData': MdiIcons.faceManShimmer,
      'color': Colors.brown.shade300,
    },
    {
      'name': 'Gynecologist',
      'iconData': MdiIcons.humanPregnant,
      'color': Colors.pink.shade300,
    },
  ];

  bool _hasMedical = false;
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
                SizedBox(
                  height: 120,
                  child: Lottie.asset(
                    'assets/animations/logout.json',
                    repeat: false,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to log out?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title2(color: Colors.black),
                ),
                const SizedBox(height: 20),
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
      backgroundColor: Colors.white,
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
                      // Saluto + nome utente
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${getGreeting()}, \n${getUserDisplayName()}!',
                            style: AppTextStyles.title2(
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
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
                          "Let's find your \nDoctor",
                          style: AppTextStyles.bigtitle(color: Colors.black),
                        ),
                      ] else ...[
                        // utente già compilato → titolo in alto
                        Text(
                          "Let's find your \nDoctor",
                          style: AppTextStyles.bigtitle(color: Colors.black),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // 3) search bar personalizzata (leggermente più alta)
                      Container(
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
                            Material(
                              color: Colors.deepPurple[300],
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

                // MINI TITOLO "Specialists"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Specialists',
                      style: AppTextStyles.buttons(color: Colors.deepPurple),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // CATEGORIE SCORREVOLI ORIZZONTALMENTE (4×4 leggermente più grandi)
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => SpecialistPage(
                                    specialty: cat['name'],
                                    doctors: doctors,
                                  ),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 160,
                          child: CategoryCard(
                            iconData: cat['iconData'],
                            categoryName: cat['name'],
                            backgroundColor: cat['color'],
                            isSelected: selectedSpecialty == cat['name'],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
