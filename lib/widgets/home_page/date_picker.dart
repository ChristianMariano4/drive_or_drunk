import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DatePicker extends StatefulWidget {
  final IconData icon;
  final String labelText;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const DatePicker({
    super.key,
    required this.icon,
    required this.labelText,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime? selectedDate;

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.initialDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = context.watch<ThemeProvider>().themeMode == ThemeMode.light;
    final fillColor = Theme.of(context).inputDecorationTheme.fillColor;

    return Expanded(
      child: TextField(
        readOnly: true,
        onTap: _selectDate,
        decoration: InputDecoration(
          hintText: "Pick a Date",
          prefixIcon: const Icon(Icons.calendar_today),
          filled: true,
          fillColor: isLight ? AppColors.grey : fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
