import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medicare_app/util/category_card.dart';
import 'package:medicare_app/util/doctor_card.dart';
import 'package:medicare_app/pages/medical_card_page.dart';
import 'package:medicare_app/pages/appointment_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Lista di medici con specializzazione
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

  // Lista dei medici filtrata
  List<Map<String, String>> filteredDoctors = [];

  // Controller per la ricerca
  TextEditingController _searchController = TextEditingController();

  // Specialità selezionata
  String selectedSpecialty = 'All';

  @override
  void initState() {
    super.initState();
    filteredDoctors = doctors; // All'inizio mostriamo tutti i medici
  }

  // Funzione per filtrare i medici
  void _filterDoctors(String query) {
    List<Map<String, String>> results = [];
    if (query.isEmpty && selectedSpecialty == 'All') {
      results =
          doctors; // Se la query è vuota e non è stata selezionata una specialità, mostriamo tutti i medici
    } else {
      results =
          doctors.where((doctor) {
            bool matchesName = doctor['name']!.toLowerCase().contains(
              query.toLowerCase(),
            );
            bool matchesSpecialty =
                selectedSpecialty == 'All' ||
                doctor['specialty'] == selectedSpecialty;
            return matchesName &&
                matchesSpecialty; // Filtra per nome e specialità
          }).toList();
    }
    setState(() {
      filteredDoctors = results; // Aggiorna la lista filtrata
    });
  }

  // Metodo per cambiare la specialità selezionata
  void _onSpecialtyChanged(String? newSpecialty) {
    setState(() {
      selectedSpecialty =
          newSpecialty ?? 'All'; // Imposta la specialità selezionata
    });
    _filterDoctors(_searchController.text); // Rifa il filtraggio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            //app bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //name
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
                        'Martina Castelli',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),

                  //profile picture
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.person),
                  ),
                ],
              ),
            ),

            SizedBox(height: 25),

            //card -> how do you feel?
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
                    // animation or cute picture
                    Container(
                      height: 100,
                      width: 100,
                      child: Lottie.network(
                        'https://assets2.lottiefiles.com/packages/lf20_tutvdkg0.json',
                      ),
                    ),
                    SizedBox(width: 20),
                    //how do you feel? + button
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

            // Barra di ricerca
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
                  onChanged: _filterDoctors, // Funzione di ricerca
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    hintText: 'Type doctor name',
                  ),
                ),
              ),
            ),

            SizedBox(height: 25),

            // Dropdown per selezionare la specialità
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

            // Lista dei medici filtrata
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

            // Lista dei medici filtrata in base alla specialità e ricerca
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
