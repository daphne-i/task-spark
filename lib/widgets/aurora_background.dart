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
            // "Deep Midnight" Colors
            Color(0xFF0D1B2A), // Very Dark Blue (Onyx)
            Color(0xFF1B263B), // Dark Steel Blue
            Color(0xFF003C43), // Very Dark Teal
            Color(0xFF2F2F2F), // Dark Grey
          ]
        : const [
            // "Subtle Gleam" Colors (Unchanged)
            Color(0xFFA1C4FD),
            Color(0xFFFBC2EB),
            Color(0xFFFFF9C4),
            Color(0xFFB2DFDB),
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
