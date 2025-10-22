import 'package:animated_gradient_background/animated_gradient_background.dart';
import 'package:flutter/material.dart';

class AuroraBackground extends StatelessWidget {
  // 1. We add a 'child' property
  final Widget child;

  const AuroraBackground({
    super.key,
    required this.child, // 2. We make it required
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final colors = isDarkMode
        ? const [
            // "Midnight" Colors
            Color(0xFF0D47A1),
            Color(0xFF4A148C),
            Color(0xFFAD1457),
            Color(0xFF004D40),
          ]
        : const [
            // "Gleam" Colors
            Color(0xFF4FC3F7),
            Color(0xFFF06292),
            Color(0xFFFFD54F),
            Color(0xFF81C784),
          ];

    // 3. Return the widget from the package
    return AnimatedGradientBackground(
      colors: colors,
      duration: const Duration(seconds: 10),

      // 4. Pass our 'child' property to the package's 'child'
      child: child,
      // 5. 'blur' property is removed
    );
  }
}
