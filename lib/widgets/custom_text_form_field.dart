import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/features/authentication/register_page.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Icon? prefIcon;
  final IconButton? sufIcon;
  final TextInputType? keyboardType;
  final List<DateInputFormatter>? inputFormatters;

  const CustomTextFormField(
      {super.key,
      required this.controller,
      required this.labelText,
      this.obscureText = false,
      this.validator,
      this.prefIcon,
      this.sufIcon,
      this.keyboardType,
      this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefIcon,
        suffixIcon: sufIcon,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.grey, width: 1.5),
        ),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.yellow, width: 2.0)),
        fillColor: AppColors.white,
      ),
    );
  }
}
