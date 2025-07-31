import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1976D2);
  static const primaryMaterialColor = MaterialColor(
    0xFF1976D2,
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(0xFF1976D2),
      600: Color(0xFF1565C0),
      700: Color(0xFF0D47A1),
      800: Color(0xFF0D47A1),
      900: Color(0xFF0D47A1),
    },
  );
  static const secondaryText = Color(0xFF757575);
  static const error = Color(0xFFD32F2F);

  static var primaryText;

  static var success;
}