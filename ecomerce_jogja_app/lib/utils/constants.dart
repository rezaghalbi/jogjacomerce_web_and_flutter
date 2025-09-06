import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'I-COMMERCE YOGYAKARTA';

  // Base URL
  static String baseUrl = 'https://7f5d294ac7c5.ngrok-free.app';

  // API Endpoints
  static String get loginUrl => '$baseUrl/api/users/login';
  static String get registerUrl => '$baseUrl/api/users/register';
  static String get profileUrl => '$baseUrl/api/users/profile';
  static String get productsUrl => '$baseUrl/api/products';

  // Colors
  static const Color primaryColor = Color(0xff648286);
  static const Color accentColor = Color(0xFFFFC107);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF333333);
  static const Color greyColor = Color(0xFF9E9E9E);
  static const Color lightGreyColor = Color(0xFFEEEEEE);
}
