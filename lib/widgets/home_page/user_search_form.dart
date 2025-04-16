import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/widgets/custom_filled_button.dart';
import 'package:flutter/material.dart';

class UserSearchForm extends StatelessWidget {
  const UserSearchForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.md),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.grey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),

          // Place & Date Filters
          Row(
            children: [
              // Place Filter
              Expanded(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "Select Place",
                    prefixIcon: const Icon(Icons.place),
                    filled: true,
                    fillColor: AppColors.grey,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.borderRadiusLg),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),

              Expanded(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "Pick a Date",
                    prefixIcon: const Icon(Icons.calendar_today),
                    filled: true,
                    fillColor: AppColors.grey,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.borderRadiusLg),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.defaultSpace),

          // Search Button
          CustomFilledButton(
            onPressed: () {
              // TODO:trigger search
            },
            labelText: "Search",
          ),
        ],
      ),
    );
  }
}
