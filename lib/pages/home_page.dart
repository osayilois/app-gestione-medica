import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medicare_app/util/category_card.dart';
import 'package:medicare_app/util/doctor_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
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
                          Container(
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 25),
            //search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    hintText: 'How can we help you?',
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),

            //horizontal listview -> categories : dentist, surgeon etc..
            Container(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  CategoryCard(
                    categoryName: 'Dentist',
                    IconImagePath: 'lib/icons/tooth.png',
                  ),
                  CategoryCard(
                    categoryName: 'Surgeon',
                    IconImagePath: 'lib/icons/surgery.png',
                  ),
                  CategoryCard(
                    categoryName: 'Pharmacist',
                    IconImagePath: 'lib/icons/capsules.png',
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),

            //doctor list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Doctor list',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),

            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  DoctorCard(
                    doctorImagePath:
                        'lib/images/humberto-chavez-FVh_yqLR9eA-unsplash.jpg',
                    rating: '4.9',
                    doctorName: 'Dr. Amanda Chavez',
                    doctorProfession: 'Therapist',
                  ),

                  DoctorCard(
                    doctorImagePath:
                        'lib/images/jeremy-alford-O13B7suRG4A-unsplash.jpg',
                    rating: '4.6',
                    doctorName: 'Dr. Jeremy Alford',
                    doctorProfession: 'Dentist',
                  ),

                  DoctorCard(
                    doctorImagePath:
                        'lib/images/usman-yousaf-pTrhfmj2jDA-unsplash.jpg',
                    rating: '5.0',
                    doctorName: 'Dr. Usman Yousaf',
                    doctorProfession: 'Surgeon',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
