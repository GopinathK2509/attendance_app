import 'package:flutter/material.dart';

class AppTheme {
  static const Map<String, Color> attendanceStatusColors = {
    'active': Colors.green,
    'short': Colors.red,
    'medium': Colors.orange,
    'long': Colors.blue,
  };

  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.deepPurple,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: Colors.deepPurple,
    ),
    scaffoldBackgroundColor: Colors.grey[100],
  );
}
