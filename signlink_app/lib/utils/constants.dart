import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF003366);
  static const primaryLight = Color(0xFF1A4D8C);
  static const primaryDark = Color(0xFF00224D);
  static const accent = Color(0xFF0066CC);
  static const background = Color(0xFFF5F7F8);
  static const backgroundDark = Color(0xFF0F1923);
  static const surface = Colors.white;
  static const error = Color(0xFFDC2626);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textHint = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
  // Aliases / extra colours
  static const secondary = accent;
  static const inputFill = Color(0xFFF1F5F9);
}

class AppStrings {
  static const appName = 'SignLink';
  static const tagline = 'Connecting Students & Interpreters';
  static const university = 'Ashesi University';
  static const department = 'Disability & Academic Support Services';

  // Roles
  static const roleStudent = 'student';
  static const roleInterpreter = 'interpreter';
  static const roleAdmin = 'admin';

  // Auth
  static const login = 'Log In';
  static const signUp = 'Sign Up';
  static const logout = 'Sign Out';
  static const email = 'Email';
  static const password = 'Password';
  static const forgotPassword = 'Forgot Password?';

  // Nav labels
  static const home = 'Home';
  static const schedule = 'Schedule';
  static const events = 'Events';
  static const messages = 'Messages';
  static const profile = 'Profile';
  static const requests = 'Requests';
  static const users = 'Users';
}

class AppSizes {
  static const paddingXS = 4.0;
  static const paddingSM = 8.0;
  static const paddingMD = 16.0;
  static const paddingLG = 24.0;
  static const paddingXL = 32.0;

  static const radiusSM = 8.0;
  static const radiusMD = 12.0;
  static const radiusLG = 16.0;
  static const radiusXL = 24.0;
  static const radiusFull = 999.0;

  static const iconSM = 18.0;
  static const iconMD = 24.0;
  static const iconLG = 32.0;

  static const buttonHeight = 52.0;
  static const appBarHeight = 60.0;
  static const bottomNavHeight = 72.0;
}
