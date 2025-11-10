import 'package:flutter/material.dart';
import 'package:fastscore_frontend/widgets/sidebar.dart';
import 'package:fastscore_frontend/widgets/bottom_nav_bar.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final bool showNavigation;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.showNavigation = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        if (isMobile) {
          // Mobile layout with bottom navigation
          return Scaffold(
            body: child,
            bottomNavigationBar: showNavigation ? const AppBottomNavBar() : null,
          );
        } else {
          // Desktop layout with sidebar
          return Row(
            children: [
              if (showNavigation) const AppSidebar(),
              Expanded(child: child),
            ],
          );
        }
      },
    );
  }
}
