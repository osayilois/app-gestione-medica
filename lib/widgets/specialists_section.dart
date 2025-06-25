// lib/widgets/specialists_section.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:medicare_app/util/category_card.dart';
import 'package:medicare_app/theme/text_styles.dart';

// Per gestire filtro dinamico potresti usare un StatefullWidget
class SpecialistsSection extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final List<Map<String, String>> doctors;
  final String selectedSpecialty;
  final ValueChanged<String> onCategoryTap;

  const SpecialistsSection({
    Key? key,
    required this.categories,
    required this.doctors,
    required this.selectedSpecialty,
    required this.onCategoryTap,
  }) : super(key: key);

  @override
  State<SpecialistsSection> createState() => _SpecialistsSectionState();

  // Facoltativo: fornisci un metodo statico per filtro esterno
  static _SpecialistsSectionState? of(BuildContext context) {
    return context.findAncestorStateOfType<_SpecialistsSectionState>();
  }
}

class _SpecialistsSectionState extends State<SpecialistsSection> {
  String _currentFilter = '';

  void filter(String query) {
    setState(() {
      _currentFilter = query;
      // qui puoi gestire filtraggio interno se vuoi
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mini-titolo
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
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              final cat = widget.categories[index];
              return GestureDetector(
                onTap: () {
                  widget.onCategoryTap(cat['name']);
                },
                child: SizedBox(
                  width: 160,
                  child: CategoryCard(
                    iconData: cat['iconData'],
                    categoryName: cat['name'],
                    backgroundColor: cat['color'],
                    isSelected: widget.selectedSpecialty == cat['name'],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
