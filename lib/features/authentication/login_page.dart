import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/core/constants/image_strings.dart';
import 'package:drive_or_drunk_app/core/theme/wavy_clipper.dart';
import 'package:drive_or_drunk_app/features/authentication/auth_provider.dart';
import 'package:drive_or_drunk_app/utils/validation.dart';
import 'package:drive_or_drunk_app/widgets/custom_elevated_button.dart';
import 'package:drive_or_drunk_app/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  bool _rememberMe = false;
  bool _hidePassword = true;

  // Flag to track if navigation is in progress
  bool _isNavigating = false;

  final storage = const FlutterSecureStorage();

  Future<void> _loadCredentials() async {
    try {
      final email = await storage.read(key: 'email');
      final password = await storage.read(key: 'password');
      final rememberFlag = await storage.read(key: 'rememberMe') == 'true';

      if (email != null && password != null && rememberFlag) {
        _emailController.text = email;
        _passwordController.text = password;
        if (mounted) {
          setState(() {
            _rememberMe = rememberFlag;
          });
        }
      }
    } catch (e) {
      // Handle error silently - don't update state if there's an issue
      debugPrint('Error loading credentials: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    // Create an animation controller with a duration of 1 second
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    // Define an animation that scales the image
    _animation = Tween<double>(begin: 4.0, end: 2.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Load credentials after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCredentials();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle normal login
  void _login() async {
    if (_formKey.currentState!.validate()) {
      if (mounted) {
        setState(() => _isLoading = true);
      }

      try {
        await context.read<AuthProvider>().signIn(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // Only save credentials if we're still mounted
        if (mounted) {
          if (_rememberMe) {
            await storage.write(key: 'email', value: _emailController.text);
            await storage.write(
                key: 'password', value: _passwordController.text);
            await storage.write(key: 'rememberMe', value: 'true');
          } else {
            await storage.delete(key: 'email');
            await storage.delete(key: 'password');
            await storage.delete(key: 'rememberMe');
          }

          // Set navigating flag before navigation
          _isNavigating = true;
          Navigator.pushReplacementNamed(context, AppRoutes.navMenu);
        }
      } catch (e) {
        // Only show error if we're still mounted
        if (mounted) {
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      } finally {
        // Only update state if not navigating and still mounted
        if (mounted && !_isNavigating) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // Handle Google sign-in
  void _signInWithGoogle() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final success = await context.read<AuthProvider>().signInWithGoogle();

      // Only navigate if sign-in was successful and we're still mounted
      if (mounted) {
        _isNavigating = true;
        Navigator.pushReplacementNamed(context, AppRoutes.navMenu);
      }
    } catch (e) {
      // Only show error if we're still mounted
      if (mounted) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Google sign-in failed: ${e.toString()}')),
        );
      }
    } finally {
      // Only update state if not navigating and still mounted
      if (mounted && !_isNavigating) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive calculations
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen =
        screenSize.width < 360 || screenSize.height < 680;
    final bool isLandscape = screenSize.width > screenSize.height;

    // Calculate responsive spacing
    final double verticalSpacing =
        screenSize.height * 0.03; // 3% of screen height

    // Adjust logo container height based on orientation
    final double logoContainerHeight =
        isLandscape ? screenSize.height * 0.35 : screenSize.height * 0.45;

    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
      child: Column(children: [
        ClipPath(
          clipper: WavyClipper(),
          child: Container(
            color: AppColors.primaryColor,
            child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                      scale: _animation.value,
                      child: Container(
                        height: logoContainerHeight,
                        alignment: Alignment.center,
                        child: Image.asset(
                          Images.logo,
                          width: isSmallScreen ? 120 : 150,
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
                  padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.06,
                      vertical: AppSizes.sm),
                  child: Column(
                    children: [
                      CustomTextFormField(
                          controller: _emailController,
                          labelText: "Email",
                          validator: (value) =>
                              Validation.validateEmail(value)),
                      SizedBox(height: verticalSpacing),
                      CustomTextFormField(
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        labelText: "Password",
                        validator: (value) =>
                            Validation.validateEmptyText('Password', value),
                        sufIcon: IconButton(
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  _hidePassword = !_hidePassword;
                                });
                              }
                            },
                            icon: Icon(_hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off)),
                      ),
                      SizedBox(height: verticalSpacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left side: Remember me
                          Row(
                            children: [
                              Transform.scale(
                                scale: isSmallScreen ? 0.9 : 1.0,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    if (mounted) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    }
                                  },
                                ),
                              ),
                              Text(
                                'Remember me',
                                style: TextStyle(
                                  fontSize: isSmallScreen
                                      ? AppSizes.fontSizeSm
                                      : AppSizes.fontSizeMd,
                                ),
                              ),
                            ],
                          ),

                          // Right side: Forgot Password
                          GestureDetector(
                            onTap: () {
                              if (mounted) {
                                Navigator.pushNamed(
                                    context, AppRoutes.recoverPassword);
                              }
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: isSmallScreen
                                    ? AppSizes.fontSizeSm
                                    : AppSizes.fontSizeMd,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: verticalSpacing),
                      SizedBox(
                        width: isLandscape
                            ? screenSize.width * 0.5
                            : double.infinity,
                        child: CustomElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            labelText: 'Login'),
                      ),
                      SizedBox(height: verticalSpacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                                fontSize: isSmallScreen
                                    ? AppSizes.fontSizeSm
                                    : AppSizes.fontSizeMd),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (mounted) {
                                      Navigator.pushNamed(
                                          context, AppRoutes.register);
                                    }
                                  },
                            child: Text('SIGN UP',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen
                                        ? AppSizes.fontSizeSm
                                        : AppSizes.fontSizeMd)),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: isLandscape
                            ? screenSize.width * 0.5
                            : double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _signInWithGoogle,
                          icon: SvgPicture.asset(
                            'assets/icons/google_logo.svg',
                            height: isSmallScreen
                                ? AppSizes.iconSm
                                : AppSizes.iconMd,
                            width: isSmallScreen
                                ? AppSizes.iconSm
                                : AppSizes.iconMd,
                          ),
                          label: Text(
                            'Sign in with Google',
                            style: TextStyle(
                              fontSize: isSmallScreen
                                  ? AppSizes.fontSizeSm
                                  : AppSizes.fontSizeMd,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen
                                    ? AppSizes.cardRadiusSm
                                    : AppSizes.cardRadiusMd,
                                horizontal: isSmallScreen
                                    ? AppSizes.cardRadiusMd
                                    : AppSizes.cardRadiusLg),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))),
      ]),
    )));
  }
}
