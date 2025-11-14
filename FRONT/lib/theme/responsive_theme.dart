import 'package:flutter/material.dart';

class ResponsiveTheme {
  static BoxDecoration get flagsBackgroundDecoration {
    return const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/flagsCollage.jpg'),
        fit: BoxFit.cover,
        opacity: 0.3,
      ),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF667eea),
          Color(0xFF764ba2),
          Color(0xFF667eea),
        ],
        stops: [0.0, 0.5, 1.0],
      ),
    );
  }

  static double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  static double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200;
  }

  static int getGridCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }
}