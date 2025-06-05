import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/core/theme/wavy_clipper.dart';
import 'package:drive_or_drunk_app/features/authentication/auth_provider.dart';
import 'package:drive_or_drunk_app/utils/validation.dart';
import 'package:drive_or_drunk_app/widgets/custom_elevated_button.dart';
import 'package:drive_or_drunk_app/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordRecoverPage extends StatefulWidget {
  const PasswordRecoverPage({super.key});

  @override
  State<PasswordRecoverPage> createState() => _PasswordRecoverPageState();
}

class _PasswordRecoverPageState extends State<PasswordRecoverPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  void _submit(BuildContext context) {
    // Validate the form first
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      context.read<AuthProvider>().resetPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent.")));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipPath(
          clipper: WavyClipper(),
          child: Container(
            color: AppColors.primaryColor,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.17,
              alignment:
                  Alignment.lerp(Alignment.center, Alignment.topLeft, 0.40),
              child: Row(children: [
                Padding(
                    padding: const EdgeInsets.all(AppSizes.horizontalPadding),
                    child: CircleAvatar(
                        backgroundColor: AppColors.yellow,
                        radius: 24,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back,
                              color: AppColors.primaryColor),
                          iconSize: 25,
                          tooltip: 'Back',
                        ))),
                const Text("Forgot your password?",
                    style: TextStyle(fontSize: 25, color: AppColors.white))
              ]),
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    "No worries. Enter your email and we'll send you a link to reset it.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSizes.defaultSpace),
                  CustomTextFormField(
                    labelText: "Email",
                    controller: _emailController,
                    validator: (value) => Validation.validateEmail(value),
                  ),
                  const SizedBox(height: AppSizes.defaultSpace),
                  CustomElevatedButton(
                    onPressed: () => _submit(context),
                    labelText: "Continue",
                  ),
                ],
              ),
            )),
      ])),
    ));
  }
}
