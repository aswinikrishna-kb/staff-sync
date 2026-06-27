import 'package:flutter/material.dart';

class AppColors {
  // Peacock theme
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardColor = Color(0xFFFFFFFF);

  static const Color peacockLight = Color(0xFFB2DFDB);
  static const Color peacock = Color(0xFF4DB6AC);
  static const Color peacockDark = Color(0xFF00897B);

  static const Color primaryDark = peacockDark;
  static const Color primaryGrey = peacock;

  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color white24 = Colors.white24;
  static const Color black = Colors.black87;
  static const Color black54 = Colors.black54;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [peacockLight, peacock, peacockDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [peacock, peacockDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient appBarGradient = LinearGradient(
    colors: [peacockDark, Color(0xFF00695C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
