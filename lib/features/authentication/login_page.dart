import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/core/constants/constants.dart';
import 'package:drive_or_drunk_app/core/constants/global_keys.dart'
    show GlobalKeys;
import 'package:drive_or_drunk_app/core/constants/image_strings.dart';
import 'package:drive_or_drunk_app/core/theme/wavy_clipper.dart';
import 'package:drive_or_drunk_app/features/authentication/auth_provider.dart';
import 'package:drive_or_drunk_app/services/user_service.dart';
import 'package:drive_or_drunk_app/utils/validation.dart';
import 'package:drive_or_drunk_app/widgets/custom_elevated_button.dart';
import 'package:drive_or_drunk_app/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// Responsive Login Page
/// ------------------------------------------------------------
/// * Mobile (width < 600)  : Column layout with scroll.
/// * Tablet landscape      : Split view (logo | form).
/// * Desktop (width >=900) : Split view (logo | form) with max-width 480 for form.
/// ------------------------------------------------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _hidePassword = true;

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
          setState(() => _rememberMe = rememberFlag);
        }
      }
    } catch (e) {
      debugPrint('${ConstantsText.credentialLoginErrorText}$e');
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    _animation = Tween<double>(begin: 4.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCredentials());
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!GlobalKeys.loginFormKey.currentState!.validate()) return;

    if (mounted) setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (_rememberMe) {
        await storage.write(key: 'email', value: _emailController.text);
        await storage.write(key: 'password', value: _passwordController.text);
        await storage.write(key: 'rememberMe', value: 'true');
      } else {
        await storage.deleteAll();
      }

      UserService().refreshUser();

      if (mounted) {
        _isNavigating = true;
        Navigator.pushReplacementNamed(context, AppRoutes.navMenu);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted && !_isNavigating) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().signInWithGoogle();
      UserService().refreshUser();
      if (mounted) {
        _isNavigating = true;
        Navigator.pushReplacementNamed(context, AppRoutes.navMenu);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ConstantsText.googleSignInErrorText}$e')),
        );
      }
    } finally {
      if (mounted && !_isNavigating) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          final double maxHeight = constraints.maxHeight;
          final bool isDesktop = maxWidth >= 900;
          final bool isTabletLandscape =
              maxWidth >= 600 && maxWidth < 900 && maxWidth > maxHeight;

          final Widget header = _buildHeader(constraints);
          final Widget form = _buildForm(context, constraints);

          if (isDesktop) {
            return Row(
              children: [
                Expanded(child: header),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: form,
                  ),
                ),
              ],
            );
          }

          if (isTabletLandscape) {
            return Row(
              children: [
                Expanded(flex: 2, child: header),
                Expanded(flex: 3, child: Center(child: form)),
              ],
            );
          }

          // Mobile / portrait
          return Column(
            children: [
              header,
              Expanded(child: form),
            ],
          );
        },
      ),
    );
  }

  /* -------------------------------------------------------------------------
   *  Header (logo & wave)
   * ---------------------------------------------------------------------- */
  Widget _buildHeader(BoxConstraints constraints) {
    final double maxWidth = constraints.maxWidth;
    final double maxHeight = constraints.maxHeight;
    final bool isLandscape = maxWidth > maxHeight;
    final bool isMobile = maxWidth < 600;
    final double headerHeight = isLandscape ? maxHeight : maxHeight * 0.4;
    final double logoSize = isMobile ? 120 : (maxWidth >= 900 ? 200 : 150);

    return ClipPath(
      clipper: WavyClipper(),
      child: Container(
        height: headerHeight,
        width: double.infinity,
        color: AppColors.primaryColor,
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (_, child) => Transform.scale(
            scale: _animation.value,
            child: Image.asset(Images.logo, width: logoSize),
          ),
        ),
      ),
    );
  }

  /* -------------------------------------------------------------------------
   *  Login form
   * ---------------------------------------------------------------------- */
  Widget _buildForm(BuildContext context, BoxConstraints constraints) {
    final double maxWidth = constraints.maxWidth;
    final double maxHeight = constraints.maxHeight;
    final bool isLandscape = maxWidth > maxHeight;
    final bool isSmallWidth = maxWidth < 360;
    final bool isSmallHeight = maxHeight < 680;

    // Sizes used throughout the form
    final double horizontalPadding =
        isLandscape ? AppSizes.md : (maxWidth * 0.08).clamp(16.0, 32.0);

    final bool isTiny = isSmallWidth || isSmallHeight;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: AppSizes.md,
      ),
      child: Form(
        key: GlobalKeys.loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextFormField(
              controller: _emailController,
              labelText: ConstantsText.emailLabel,
              validator: Validation.validateEmail,
            ),
            const SizedBox(height: AppSizes.md),
            CustomTextFormField(
              controller: _passwordController,
              obscureText: _hidePassword,
              labelText: ConstantsText.passwordLabel,
              validator: (value) => Validation.validateEmptyText(
                  ConstantsText.passwordLabel, value),
              sufIcon: IconButton(
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
                icon: Icon(
                  _hidePassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            // Remember me & Forgot password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Remember me
                Row(
                  children: [
                    Transform.scale(
                      scale: isTiny ? 0.9 : 1.0,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) =>
                            setState(() => _rememberMe = value ?? false),
                      ),
                    ),
                    Text(
                      ConstantsText.rememberMeText,
                      style: TextStyle(
                        fontSize:
                            isTiny ? AppSizes.fontSizeSm : AppSizes.fontSizeMd,
                      ),
                    ),
                  ],
                ),
                // Forgot password
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.recoverPassword),
                  child: Text(
                    ConstantsText.forgotPasswordText,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize:
                          isTiny ? AppSizes.fontSizeSm : AppSizes.fontSizeMd,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            // Login button
            SizedBox(
              width: isLandscape ? maxWidth * 0.5 : double.infinity,
              child: CustomElevatedButton(
                onPressed: _isLoading ? null : _login,
                labelText: ConstantsText.loginButtonText,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            // Sign up
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ConstantsText.dontHaveAccountText,
                  style: TextStyle(
                    fontSize:
                        isTiny ? AppSizes.fontSizeSm : AppSizes.fontSizeMd,
                  ),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.pushNamed(context, AppRoutes.register),
                  child: Text(
                    ConstantsText.signUpButtonText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          isTiny ? AppSizes.fontSizeSm : AppSizes.fontSizeMd,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: Row(
                children: [
                  const Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSizes.md),
                    child: Text(
                      ConstantsText.continueWith,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Google sign-in
            SizedBox(
              width: isLandscape ? maxWidth * 0.5 : double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _signInWithGoogle,
                icon: SvgPicture.asset(
                  Images.googleLogo,
                  height: isTiny ? AppSizes.iconSm : AppSizes.iconMd,
                  width: isTiny ? AppSizes.iconSm : AppSizes.iconMd,
                ),
                label: Text(
                  ConstantsText.googleSignInText,
                  style: TextStyle(
                    fontSize:
                        isTiny ? AppSizes.fontSizeSm : AppSizes.fontSizeMd,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical:
                        isTiny ? AppSizes.cardRadiusSm : AppSizes.cardRadiusMd,
                    horizontal:
                        isTiny ? AppSizes.cardRadiusMd : AppSizes.cardRadiusLg,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
