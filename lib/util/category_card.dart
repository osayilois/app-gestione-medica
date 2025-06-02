import 'package:flutter/material.dart';
import 'package:medicare_app/theme/text_styles.dart';

class CategoryCard extends StatelessWidget {
  final IconData iconData;
  final String categoryName;
  final Color backgroundColor;

  const CategoryCard({
    super.key,
    required this.iconData,
    required this.categoryName,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // riduce lo spazio orizzontale tra le card
      padding: const EdgeInsets.only(right: 12.0),
      child: Container(
        // larghezza fissa per avvicinarle a un rapporto “4x4”
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // cerchio bianco con icona colorata come lo sfondo
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(iconData, size: 28, color: backgroundColor),
            ),
            const SizedBox(height: 12),
            Text(
              categoryName,
              textAlign: TextAlign.center,
              style: AppTextStyles.buttons(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
