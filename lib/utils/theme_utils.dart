import 'package:flutter/material.dart';

bool isThemeDark(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}
