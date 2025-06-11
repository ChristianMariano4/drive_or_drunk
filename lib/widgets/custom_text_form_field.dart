import 'dart:ffi';

import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/features/authentication/register_page.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Icon? prefIcon;
  final Widget? sufIcon;
  final TextInputType? keyboardType;
  final List<DateInputFormatter>? inputFormatters;
  final bool isChatForm;

  const CustomTextFormField(
      {super.key,
      required this.controller,
      required this.labelText,
      this.obscureText = false,
      this.validator,
      this.prefIcon,
      this.sufIcon,
      this.keyboardType,
      this.inputFormatters,
      this.isChatForm = false});

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
          enabledBorder: UnderlineInputBorder(
            borderRadius:
                isChatForm ? BorderRadius.circular(16) : BorderRadius.zero,
            borderSide: const BorderSide(color: AppColors.grey, width: 1.5),
          ),
          focusedBorder: UnderlineInputBorder(
              borderRadius:
                  isChatForm ? BorderRadius.circular(16) : BorderRadius.zero,
              borderSide: isChatForm
                  ? const BorderSide(color: AppColors.primaryColor, width: 2.0)
                  : const BorderSide(color: AppColors.yellow, width: 2.0)),
          fillColor: isChatForm ? AppColors.grey : AppColors.white),
    );
  }
}
