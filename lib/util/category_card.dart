// lib/util/category_card.dart

import 'package:flutter/material.dart';
import 'package:medicare_app/theme/text_styles.dart';

class CategoryCard extends StatelessWidget {
  final IconData iconData;
  final String categoryName;
  final Color backgroundColor;
  final bool isSelected;

  const CategoryCard({
    super.key,
    required this.iconData,
    required this.categoryName,
    required this.backgroundColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0), // leggermente più vicine
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? backgroundColor.withOpacity(0.7) : backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: backgroundColor.withOpacity(0.4),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cerchio bianco con icona colorata
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(iconData, size: 32, color: backgroundColor),
            ),
            const SizedBox(height: 8),
            Text(
              categoryName,
              style: AppTextStyles.buttons(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
