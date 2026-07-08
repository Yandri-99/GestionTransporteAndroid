import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle headlineBold(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold);
  }

  static TextStyle titleBold(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold);
  }

  static TextStyle body(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!;
  }

  static TextStyle caption(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!;
  }
}
