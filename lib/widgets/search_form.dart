import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/widgets/custom_filled_button.dart';
import 'package:flutter/material.dart';

class SearchForm extends StatelessWidget {
  const SearchForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            // Arrival
            _buildInputTile(
              Icons.location_on_outlined,
              "Milan, Pene Club",
            ),
            const SizedBox(
              height: 8,
            ),

            // Date
            _buildInputTile(Icons.calendar_today, "lun 4 ago"),
            const SizedBox(height: AppSizes.md),

            // Button
            CustomFilledButton(
              onPressed: () {
                // something
              },
              labelText: "Search",
            )
          ],
        ));
  }
}

Widget _buildInputTile(IconData icon, String text, {IconData? trailing}) {
  return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
          color: const Color(0x1C06416E),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          if (trailing != null) Icon(trailing, size: 18, color: Colors.grey)
        ],
      ));
}
