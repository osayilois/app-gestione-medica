// lib/widgets/home_header.dart
import 'package:flutter/material.dart';
import 'package:medicare_app/theme/text_styles.dart';

class HomeHeader extends StatelessWidget {
  final String Function() getGreeting;
  final String Function() getUserDisplayName;

  const HomeHeader({
    Key? key,
    required this.getGreeting,
    required this.getUserDisplayName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder: mostra semplicemente il saluto
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${getGreeting()},\n${getUserDisplayName()}!',
                style: AppTextStyles.title2(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
            ],
          ),
          // eventualmente un avatar o altro, qui omesso
        ],
      ),
    );
  }
}
