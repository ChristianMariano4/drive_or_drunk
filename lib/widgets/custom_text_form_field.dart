import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/features/authentication/register_page.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Icon? prefIcon;
  final Widget? sufIcon;
  final TextInputType? keyboardType;
  final List<DateInputFormatter>? inputFormatters;
  final int type;

  const CustomTextFormField(
      {super.key,
      required this.controller,
      this.labelText,
      this.obscureText = false,
      this.validator,
      this.prefIcon,
      this.sufIcon,
      this.keyboardType,
      this.inputFormatters,
      this.type = 0});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      maxLines: type != 0 ? 21 : 1,
      minLines: 1,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
          labelText: labelText,
          border: type == 2
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(width: 1.5),
                )
              : null,
          prefixIcon: prefIcon,
          suffixIcon: sufIcon,
          enabledBorder: UnderlineInputBorder(
            borderRadius:
                type == 1 ? BorderRadius.circular(16) : BorderRadius.zero,
            borderSide: type == 2
                ? const BorderSide(color: Colors.transparent, width: 0)
                : const BorderSide(color: AppColors.grey, width: 1.5),
          ),
          focusedBorder: UnderlineInputBorder(
              borderRadius:
                  type == 1 ? BorderRadius.circular(16) : BorderRadius.zero,
              borderSide: type == 1
                  ? const BorderSide(color: AppColors.primaryColor, width: 2.0)
                  : type == 0
                      ? const BorderSide(color: AppColors.yellow, width: 2.0)
                      : const BorderSide(color: Colors.transparent, width: 0)),
          fillColor: type == 1 ? AppColors.grey : AppColors.white),
    );
  }
}
