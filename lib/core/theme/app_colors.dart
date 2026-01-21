import 'package:flutter/material.dart';

/// App color constants for consistent theming throughout the application
class AppColors {
  // Prevent instantiation
  AppColors._();

  // Text colors
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Color(0xffc4b5fd);

  // Background colors
  static const Color primaryBackground = Color(0xff1a0d2e);
  static const Color cardBackground = Color(0xff271845);
  static const Color buttonBackground = Color.fromARGB(164, 60, 44, 90);

  // Button colors
  static const Color primaryButton = Color(0xff6a2ae5);

  // Navigation colors
  static const Color selectedItem = Color(0xff7c3aed);

  // Text field colors
  static const Color textFieldBackground = Color(0xff271845);

  // Status colors
  static const Color error = Colors.red;
  static const Color success = Colors.green;
}
