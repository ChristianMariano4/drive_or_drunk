import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
import 'package:drive_or_drunk_app/widgets/custom_filled_button.dart';
import 'package:flutter/material.dart';
import 'package:drive_or_drunk_app/widgets/home_page/date_picker.dart';
import 'package:provider/provider.dart';

class EventSearchForm extends StatelessWidget {
  const EventSearchForm({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = context.watch<ThemeProvider>().themeMode == ThemeMode.light;
    final fillColor = Theme.of(context).inputDecorationTheme.fillColor;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.md),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search events...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: isLight ? AppColors.grey : fillColor,
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
                  decoration: InputDecoration(
                    hintText: "Select Place",
                    prefixIcon: const Icon(Icons.place),
                    filled: true,
                    fillColor: isLight ? AppColors.grey : fillColor,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.borderRadiusLg),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSizes.sm),

              DatePicker(
                icon: Icons.calendar_today,
                labelText: "Pick a Date",
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.defaultSpace),

          // Search Button
          CustomFilledButton(
            onPressed: () {
              // TODO: trigger search
            },
            labelText: "Search",
          ),
        ],
      ),
    );
  }
}
