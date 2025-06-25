// lib/widgets/search_bar.dart
import 'package:flutter/material.dart';
import 'package:medicare_app/theme/text_styles.dart';

class DoctorSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  const DoctorSearchBar({
    Key? key,
    required this.controller,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                controller: controller,
                onChanged: onSearch,
                decoration: InputDecoration(
                  hintText: 'Search doctor',
                  hintStyle: AppTextStyles.body(color: Colors.grey[600]!),
                  border: InputBorder.none,
                ),
              ),
            ),
            Material(
              color: Colors.deepPurple[300],
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => onSearch(controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
