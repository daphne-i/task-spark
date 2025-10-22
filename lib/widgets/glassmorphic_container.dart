import 'dart:ui'; // This is needed for ImageFilter.blur
import 'package:flutter/material.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Get the theme's surface color (white in light, black in dark)
    final glassColor = Theme.of(context).colorScheme.surface.withOpacity(0.2);
    // Get the theme's text color for the border
    final borderColor = Theme.of(
      context,
    ).colorScheme.onSurface.withOpacity(0.1);

    // We use ClipRRect to force the rounded corners onto its children
    return ClipRRect(
      borderRadius: BorderRadius.circular(25.0),
      child: Container(
        width: width,
        height: height,
        color: Colors
            .transparent, // Important: Make the container itself transparent
        // Stack is used to layer the blur and the content
        child: Stack(
          children: [
            // Layer 1: The Blur
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                // This container is just for the filter, it doesn't need properties
              ),
            ),

            // Layer 2: The Glass Tint and Border
            Container(
              decoration: BoxDecoration(
                color: glassColor, // The semi-transparent tint
                borderRadius: BorderRadius.circular(25.0),
                border: Border.all(
                  color: borderColor, // A very subtle border
                  width: 1.5,
                ),
              ),
            ),

            // Layer 3: The actual content
            child,
          ],
        ),
      ),
    );
  }
}
