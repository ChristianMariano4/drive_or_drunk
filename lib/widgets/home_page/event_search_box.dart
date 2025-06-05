import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventSearchBox extends StatefulWidget {
  final IconData icon;
  final String labelText;
  final String hintText;
  final String searchText;
  final ValueChanged<String?> onChanged;

  const EventSearchBox({
    super.key,
    required this.icon,
    required this.labelText,
    required this.hintText,
    required this.searchText,
    required this.onChanged,
  });

  @override
  State<EventSearchBox> createState() => _EventSearchBoxState();
}

class _EventSearchBoxState extends State<EventSearchBox> {
  String? selectedText;

  Future<void> _openSearchDialog() async {
    final controller = TextEditingController(text: selectedText ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 80.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 200),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.searchText,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(controller.text.trim());
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

    if (result != null && result.isNotEmpty) {
      setState(() {
        selectedText = result;
        widget.onChanged.call(selectedText!);
      });
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
        filled: true,
        fillColor: isLight ? AppColors.grey : fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
          borderSide: BorderSide.none,
        ),
        suffixIcon: selectedText?.isNotEmpty == true
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    selectedText = null;
                    widget.onChanged(null);
                  });
                },
              )
            : null,
      ),
    );
  }
}
