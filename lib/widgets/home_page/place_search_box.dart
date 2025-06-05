import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
import 'package:drive_or_drunk_app/utils/localizator.dart';
import 'package:drive_or_drunk_app/utils/search_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

class PlaceSearchBox extends StatefulWidget {
  final IconData icon;
  final String labelText;
  final String hintText;
  final String searchText;
  final ValueChanged<String?>? onChanged; // Added this parameter

  const PlaceSearchBox({
    super.key,
    required this.icon,
    required this.labelText,
    required this.hintText,
    required this.searchText,
    required this.onChanged, // Added this parameter
  });

  @override
  State<PlaceSearchBox> createState() => _PlaceSearchBoxState();
}

class _PlaceSearchBoxState extends State<PlaceSearchBox> {
  String? selectedText;

  Future<void> _openSearchDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        String tempText = selectedText ?? '';

        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: MediaQuery.of(context).size.height * 0.1,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.searchText,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                FutureBuilder<String?>(
                  future: getCurrentCountryCode(),
                  builder: (context, snapshot) {
                    final countryCode = snapshot.data ?? 'IT';

                    return TypeAheadField<String>(
                      suggestionsCallback: (pattern) async {
                        if (pattern.length < 2) return [];
                        return await getCitySuggestions(pattern, countryCode);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion),
                        );
                      },
                      onSelected: (suggestion) {
                        suggestion = suggestion.split(',').first.trim();
                        Navigator.of(context).pop(suggestion);
                      },
                      builder: (context, controller, focusNode) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: widget.hintText,
                            border: const OutlineInputBorder(),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(tempText);
                    },
                    child: const Text("Confirm"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        selectedText = result.trim();
      });
      // Call the onChanged callback when a place is selected
      widget.onChanged?.call(selectedText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = context.watch<ThemeProvider>().themeMode == ThemeMode.light;
    final fillColor = Theme.of(context).inputDecorationTheme.fillColor;

    return TextField(
      readOnly: true,
      onTap: _openSearchDialog,
      controller: TextEditingController(text: selectedText ?? ''),
      decoration: InputDecoration(
        hintText: widget.labelText,
        prefixIcon: Icon(widget.icon),
        suffixIcon: selectedText != null && selectedText!.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    selectedText = null;
                    widget.onChanged?.call(null);
                  });
                },
              )
            : null,
        filled: true,
        fillColor: isLight ? AppColors.grey : fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
