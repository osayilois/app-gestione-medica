import 'package:flutter/material.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/util/doctor_card.dart';
import 'package:medicare_app/pages/doctor/doctor_profile_page.dart'; // importa la pagina profilo

class TopRatedDoctorsSection extends StatelessWidget {
  /// Lista di medici: ogni mappa deve contenere almeno 'rating', 'name', 'specialty', 'image'
  final List<Map<String, String>> doctors;

  /// Soglia minima per considerare "top rated"
  final double threshold;

  const TopRatedDoctorsSection({
    Key? key,
    required this.doctors,
    this.threshold = 4.8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filtra i dottori con rating >= soglia
    final topRated =
        doctors.where((d) {
          final r = double.tryParse(d['rating'] ?? '') ?? 0;
          return r >= threshold;
        }).toList();

    if (topRated.isEmpty) {
      return const SizedBox(); // oppure un widget placeholder
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Text(
            'Top Rated Doctors',
            style: AppTextStyles.buttons(color: Colors.deepPurple),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 25),
            itemCount: topRated.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final doc = topRated[index];
              return DoctorCard(
                doctorImagePath: doc['image']!,
                rating: doc['rating']!,
                doctorName: doc['name']!,
                doctorProfession: doc['specialty']!,
                onTap: () {
                  // Naviga al profilo del dottore
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => DoctorProfilePage(
                            name: doc['name']!,
                            specialty: doc['specialty']!,
                            imagePath: doc['image']!,
                            rating: doc['rating']!,
                            bio: doc['bio'] ?? '',
                            address: doc['address'] ?? '',
                            phone: doc['phone'] ?? '',
                            email: doc['email'] ?? '',
                            hours: doc['hours'] ?? '',
                          ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
