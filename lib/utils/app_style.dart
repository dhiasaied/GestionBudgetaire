import 'package:flutter/material.dart';

class AppStyle {
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  static const BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(12));
  
  static BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: defaultBorderRadius,
    boxShadow: [
      BoxShadow(
        color: Theme.of(context).shadowColor.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static ButtonStyle elevatedButtonStyle(BuildContext context) => ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: defaultBorderRadius),
  );

  static InputDecoration inputDecoration(BuildContext context, String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: defaultBorderRadius),
    filled: true,
    fillColor: Theme.of(context).cardColor,
    enabledBorder: OutlineInputBorder(
      borderRadius: defaultBorderRadius,
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: defaultBorderRadius,
      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
    ),
  );
}
