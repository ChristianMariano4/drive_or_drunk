import 'package:drive_or_drunk_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.grey, width: 1.5),
        ),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.yellow, width: 2.0)),
        fillColor: AppColors.white,
      ),
    );
  }
  // TextFormField(
  //                           controller: _passwordController,
  //                           decoration: const InputDecoration(
  //                             labelText: 'Password',
  //                             enabledBorder: UnderlineInputBorder(
  //                               borderSide: BorderSide(
  //                                   color: Color(0xffffc953),
  //                                   width: 1.5), //TODO: fix color
  //                             ),

  //                           obscureText: true,
  //                           validator: (value) => value!.isEmpty
  //                               ? 'Please enter a password'
  //                               : null,
  //                         ),
}
