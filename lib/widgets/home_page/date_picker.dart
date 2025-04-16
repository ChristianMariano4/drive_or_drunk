import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';

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
    return Expanded(
      child: GestureDetector(
        onTap: _selectDate,
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
              Icon(widget.icon),
              const SizedBox(width: AppSizes.sm),
              Text(widget.labelText),
            ],
          ),
        ),
      ),
    );
  }
}
