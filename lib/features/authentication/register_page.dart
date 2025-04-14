import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/app_constants.dart';
import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/theme/wavy_clipper.dart';
import 'package:drive_or_drunk_app/features/authentication/auth_provider.dart';
import 'package:drive_or_drunk_app/widgets/custom_elevated_button.dart';
import 'package:drive_or_drunk_app/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await context.read<AuthProvider>().signUp(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              displayName: _nameController.text.trim(),
            );
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } catch (e) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipPath(
                clipper: WavyClipper(),
                child: Container(
                  color: AppColors.blue,
                  child: Container(
                      height: MediaQuery.of(context).size.height * 0.17,
                      alignment: Alignment.lerp(
                          Alignment.center, Alignment.topLeft, 0.40),
                      child: Row(children: [
                        Padding(
                            padding: const EdgeInsets.all(
                                AppConstants.horizontalPadding),
                            child: CircleAvatar(
                                backgroundColor: AppColors.yellow,
                                radius: 24,
                                child: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back,
                                      color: AppColors.blue),
                                  iconSize: 25,
                                  tooltip: 'Back',
                                ))),
                        const Text("Create Account",
                            style:
                                TextStyle(fontSize: 25, color: AppColors.white))
                      ])),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.horizontalPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextFormField(
                        controller: _nameController,
                        labelText: "Name",
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a name' : null,
                      ),
                      const SizedBox(height: 24),
                      CustomTextFormField(
                        controller: _emailController,
                        labelText: "Email",
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter an email' : null,
                      ),
                      const SizedBox(height: 24),
                      CustomTextFormField(
                        controller: _phoneController,
                        labelText: "Phone",
                      ),
                      const SizedBox(height: 24),
                      CustomTextFormField(
                        controller: _dateController,
                        labelText: "Date of birth",
                      ),
                      const SizedBox(height: 24),
                      CustomTextFormField(
                        controller: _passwordController,
                        labelText: "Password",
                        obscureText: true,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a password' : null,
                      ),
                      const SizedBox(height: 24),
                      CustomTextFormField(
                        controller: _confirmPasswordController,
                        labelText: "Confirm Password",
                        obscureText: true,
                        validator: (value) => value != _passwordController.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                      const SizedBox(height: 36),
                      CustomElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        labelText: 'Sign up',
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Don’t have an account?'),
                          const SizedBox(width: 0),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.login);
                            },
                            child: const Text('LOGIN',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      // TextButton(
                      //   onPressed: () {
                      //     Navigator.pushReplacementNamed(
                      //         context, AppRoutes.login);
                      //   },
                      //   child: const Text('Already have an account? Login'),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
