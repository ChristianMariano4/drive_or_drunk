import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';

class FormFilter extends StatelessWidget {
  final VoidCallback? searchFunction;
  final String labelText;
  final IconData icon;

  const FormFilter(
      {super.key,
      this.searchFunction,
      required this.labelText,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: searchFunction,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.horizontalPadding,
              vertical: AppSizes.verticalPadding),
          decoration: BoxDecoration(
            color: AppColors.grey,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
          ),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: AppSizes.sm),
              Text(labelText),
            ],
          ),
        ),
      ),
    );
  }
}
