import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_constants.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/core/theme/wavy_clipper.dart';
import 'package:drive_or_drunk_app/features/authentication/auth_provider.dart';
import 'package:drive_or_drunk_app/utils/validation.dart';
import 'package:drive_or_drunk_app/widgets/custom_elevated_button.dart';
import 'package:drive_or_drunk_app/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final oldText = oldValue.text;
    final newText = newValue.text;

    // Remove any existing slashes from new input
    String digitsOnly = newText.replaceAll('/', '');
    if (digitsOnly.length > 8) {
      digitsOnly = digitsOnly.substring(0, 8);
    }

    // Build the formatted text with slashes
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      if ((i == 1 || i == 3) && i != digitsOnly.length - 1) {
        buffer.write('/');
      }
    }

    final formattedText = buffer.toString();

    // Adjust the cursor position
    int selectionIndex = newValue.selection.baseOffset;

    // Count how many slashes have been added before the cursor
    int slashCount = 0;
    for (int i = 0; i < selectionIndex && i < formattedText.length; i++) {
      if (formattedText[i] == '/') {
        slashCount++;
      }
    }

    selectionIndex = newValue.selection.baseOffset + slashCount;

    // Clamp to prevent cursor overflow
    selectionIndex = selectionIndex.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

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

  String _selectedPrefix = '+39';
  final List<String> _prefixes = ['+39', '+1', '+44', '+33', '+49'];

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await context.read<AuthProvider>().signUp(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              displayName: _nameController.text.trim(),
            );
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
        navigatorKey.currentState?.pushNamed(AppRoutes.navMenu);
      } catch (e) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        constraints.maxWidth < 600 ? double.infinity : 500,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipPath(
                        clipper: WavyClipper(),
                        child: Container(
                          color: AppColors.primaryColor,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.17,
                            alignment: Alignment.lerp(
                                Alignment.center, Alignment.topLeft, 0.40),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(
                                      AppConstants.horizontalPadding),
                                  child: CircleAvatar(
                                    backgroundColor: AppColors.yellow,
                                    radius: 24,
                                    child: IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(Icons.arrow_back,
                                          color: AppColors.primaryColor),
                                      iconSize: 25,
                                      tooltip: 'Back',
                                    ),
                                  ),
                                ),
                                const Text(
                                  "Create Account",
                                  style: TextStyle(
                                      fontSize: 25, color: AppColors.white),
                                ),
                              ],
                            ),
                          ),
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
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter a name'
                                    : null,
                              ),
                              const SizedBox(height: 24),
                              CustomTextFormField(
                                controller: _emailController,
                                labelText: "Email",
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter an email'
                                    : null,
                              ),
                              const SizedBox(height: AppSizes.lg),
                              Row(
                                children: [
                                  Container(
                                    height: 56,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom:
                                            BorderSide(color: AppColors.grey),
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedPrefix,
                                        onChanged: (value) {
                                          setState(
                                              () => _selectedPrefix = value!);
                                        },
                                        items: _prefixes.map((prefix) {
                                          return DropdownMenuItem<String>(
                                            value: prefix,
                                            child: Text(prefix),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.spaceBtwItems),
                                  Expanded(
                                    child: CustomTextFormField(
                                      controller: _phoneController,
                                      labelText: "Phone",
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.lg),
                              CustomTextFormField(
                                controller: _dateController,
                                labelText: "Date of birth",
                                keyboardType: TextInputType.number,
                                inputFormatters: [DateInputFormatter()],
                                validator: Validation.validateDate,
                              ),
                              const SizedBox(height: AppSizes.lg),
                              CustomTextFormField(
                                controller: _passwordController,
                                labelText: "Password",
                                obscureText: true,
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter a password'
                                    : null,
                              ),
                              const SizedBox(height: AppSizes.lg),
                              CustomTextFormField(
                                controller: _confirmPasswordController,
                                labelText: "Confirm Password",
                                obscureText: true,
                                validator: (value) =>
                                    value != _passwordController.text
                                        ? 'Passwords do not match'
                                        : null,
                              ),
                              const SizedBox(height: AppSizes.xl),
                              CustomElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                labelText: 'Sign Up',
                              ),
                              const SizedBox(height: AppSizes.lg),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Have already an account?'),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                          context, AppRoutes.login);
                                    },
                                    child: const Text('LOGIN',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
