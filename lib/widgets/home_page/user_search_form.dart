import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
import 'package:drive_or_drunk_app/models/user_model.dart';
import 'package:drive_or_drunk_app/services/firestore_service.dart';
import 'package:drive_or_drunk_app/widgets/custom_filled_button.dart';
import 'package:drive_or_drunk_app/widgets/custom_stream_builder.dart'
    show CustomStreamBuilder;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserSearchForm extends StatefulWidget {
  const UserSearchForm({super.key});

  @override
  State<UserSearchForm> createState() => _UserSearchFormState();
}

class _UserSearchFormState extends State<UserSearchForm> {
  final TextEditingController _controller = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String _searchText = '';
  Stream<List<User>>? _searchResults;

  void _performSearch() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    Navigator.pushNamed(
      context,
      AppRoutes.usersList,
      arguments: query,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = context.watch<ThemeProvider>().themeMode == ThemeMode.light;
    final fillColor = Theme.of(context).inputDecorationTheme.fillColor;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.md),
          ),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _controller,
                onChanged: (value) => setState(() => _searchText = value),
                decoration: InputDecoration(
                  hintText: 'Search users',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isLight ? AppColors.grey : fillColor,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSizes.borderRadiusLg),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),

              // Optional filters
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "Select place",
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
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "Pick a date",
                        prefixIcon: const Icon(Icons.calendar_today),
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
                ],
              ),
              const SizedBox(height: AppSizes.defaultSpace),
              CustomFilledButton(
                onPressed: _performSearch,
                labelText: "Search",
              ),
            ],
          ),
        ),
        if (_searchResults != null)
          CustomStreamBuilder<User>(
            stream: _searchResults!,
            customListTileBuilder: (user) => ListTile(
              leading: const Icon(Icons.person),
              title: Text(user.name),
              subtitle: Text(user.email),
            ),
          ),
      ],
    );
  }
}
