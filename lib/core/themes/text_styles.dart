import 'package:flutter/material.dart';

class TextStyles {
  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontSize: 16,
    color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
  );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
    fontSize: 14,
    color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey[700],
  );

  static TextStyle attendanceDurationShort(BuildContext context) =>
      TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold);

  static TextStyle attendanceDurationMedium(BuildContext context) => TextStyle(
    fontSize: 14,
    color: Colors.orange,
    fontWeight: FontWeight.bold,
  );

  static TextStyle attendanceDurationLong(BuildContext context) =>
      TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold);
}
