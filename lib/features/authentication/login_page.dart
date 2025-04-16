import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/theme/wavy_clipper.dart';
import 'package:drive_or_drunk_app/features/authentication/auth_provider.dart';
import 'package:drive_or_drunk_app/widgets/custom_elevated_button.dart';
import 'package:drive_or_drunk_app/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool rememberMeChecked = false;

  @override
  void initState() {
    super.initState();

    // Create an animation controller with a duration of 1 second
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    // Define an animation that scales the image from 1.0 to 0.4
    _animation = Tween<double>(begin: 4.0, end: 2.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await context.read<AuthProvider>().signIn(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
        Navigator.pushReplacementNamed(context, AppRoutes.navMenu);
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
            child: SingleChildScrollView(
      child: Column(children: [
        ClipPath(
          clipper: WavyClipper(),
          child: Container(
            color: AppColors.blue, //TODO: fix color
            child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                      scale: _animation.value,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/logos/logo_android12.png',
                          width: 150,
                        ),
                      ));
                }),
          ),
        ),
        Transform.translate(
            offset: const Offset(0, -25),
            child: Form(
                key: _formKey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    children: [
                      CustomTextFormField(
                        controller: _emailController,
                        labelText: "Email",
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter an email' : null,
                      ),
                      const SizedBox(height: 24),
                      CustomTextFormField(
                        controller: _passwordController,
                        labelText: "Password",
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a password' : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //TODO implement these
                          Row(
                            children: [
                              Checkbox(
                                  value: rememberMeChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      rememberMeChecked = value ?? false;
                                    });
                                  }),
                              const Text('Remember me'),
                            ],
                          ),
                          const Text('Forget Password?'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CustomElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          labelText: 'Login'),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Don’t have an account?'),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.register);
                            },
                            child: const Text('SIGN UP',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                                context.read<AuthProvider>().signInWithGoogle();
                              },
                        icon: SvgPicture.asset(
                          'assets/icons/google_logo.svg',
                          height: 24,
                          width: 24,
                        ),
                        label: const Text('Sign in with Google'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                      ),
                      // ElevatedButton(
                      //   onPressed: _isLoading
                      //       ? null
                      //       : () {
                      //           context.read<AuthProvider>().signInWithFacebook();
                      //         },
                      //   child: Text('Sign in with Facebook'),
                      // ),
                    ],
                  ),
                ))),
      ]),
    )));
  }
}
