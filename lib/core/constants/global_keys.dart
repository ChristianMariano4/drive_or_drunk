import 'package:flutter/material.dart';

class GlobalKeys {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Form keys
  static final loginFormKey = GlobalKey<FormState>();
  static final registerFormKey = GlobalKey<FormState>();
  static final forgotPasswordFormKey = GlobalKey<FormState>();
  static final upsertEventFormKey = GlobalKey<FormState>();
  static final dateInputFormStateKey = GlobalKey<FormFieldState>();
}
