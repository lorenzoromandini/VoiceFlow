import 'package:flutter/material.dart';
import 'responsive_layout.dart';

/// Grid that adapts number of columns to screen size
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      int crossAxisCount;
      
      if (constraints.maxWidth >= Breakpoints.tablet) {
        crossAxisCount = 3; // Desktop
      } else if (constraints.maxWidth >= Breakpoints.mobile) {
        crossAxisCount = 2; // Tablet
      } else {
        crossAxisCount = 1; // Mobile
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.0,
          crossAxisSpacing: spacing,
          mainAxisSpacing: runSpacing,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      );
    });
  }
}
