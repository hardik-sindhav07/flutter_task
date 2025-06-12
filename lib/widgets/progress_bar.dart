import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const ProgressBar({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final isActive = index < current;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 20,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.progressBg,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }),
    );
  }
} 