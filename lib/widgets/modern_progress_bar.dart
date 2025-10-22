import 'package:flutter/material.dart';

class ModernProgressBar extends StatelessWidget {
  final double progress; // A value between 0.0 and 1.0

  const ModernProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    // Get the theme's surface color (white/black) for the bar's background
    final baseColor = Theme.of(context).colorScheme.surface.withOpacity(0.3);

    // Create the glossy gradient for the progress
    final progressGradient = LinearGradient(
      colors: [
        Theme.of(context).colorScheme.primary, // Blue
        Theme.of(context).colorScheme.secondary, // Yellow/Orange
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final double barWidth = constraints.maxWidth;
        final double progressWidth = barWidth * progress;

        return Container(
          width: barWidth,
          height: 12, // The height of the progress bar
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(
              6,
            ), // Rounded corners for the base
          ),
          child: Stack(
            children: [
              // This is the filled part of the bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: progressWidth,
                height: 12,
                decoration: BoxDecoration(
                  gradient: progressGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
