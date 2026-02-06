import 'package:flutter/material.dart';

/// Application theme based on African Leadership University branding
///
/// This class defines the color palette, text styles, and component themes
/// used throughout the app to maintain consistent ALU branding
class AppTheme {
  // ALU Brand Colors extracted from the design mockups
  static const Color navyBlue = Color(0xFF0A1128);
  static const Color darkBlue = Color(0xFF1A2238);
  static const Color accentYellow = Color(0xFFF4C430);
  static const Color warningRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF9CA3AF);
  static const Color borderGray = Color(0xFF374151);

  // Priority colors for assignments
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF10B981);

  // Attendance status colors
  static const Color excellentAttendance = Color(0xFF10B981); // >= 85%
  static const Color goodAttendance = Color(0xFFF59E0B); // 75-84%
  static const Color atRiskAttendance = Color(0xFFEF4444); // < 75%

  /// Main app theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Primary color scheme
      primaryColor: navyBlue,
      scaffoldBackgroundColor: navyBlue,

      colorScheme: const ColorScheme.dark(
        primary: accentYellow,
        secondary: accentYellow,
        surface: darkBlue,
        error: warningRed,
        onPrimary: textDark,
        onSecondary: textDark,
        onSurface: textLight,
        onError: textLight,
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: navyBlue,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textLight),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: darkBlue,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentYellow,
          foregroundColor: textDark,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentYellow,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentYellow,
          side: const BorderSide(color: accentYellow, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentYellow,
        foregroundColor: textDark,
        elevation: 4,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: warningRed),
        ),
        labelStyle: const TextStyle(color: textGray),
        hintStyle: const TextStyle(color: textGray),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkBlue,
        selectedItemColor: accentYellow,
        unselectedItemColor: textGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: darkBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: darkBlue,
        selectedColor: accentYellow,
        disabledColor: borderGray,
        labelStyle: const TextStyle(color: textLight),
        secondaryLabelStyle: const TextStyle(color: textDark),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Text theme
      textTheme: const TextTheme(
        // Display styles
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),

        // Headline styles
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),

        // Title styles
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),

        // Body styles
        bodyLarge: TextStyle(fontSize: 16, color: textLight),
        bodyMedium: TextStyle(fontSize: 14, color: textLight),
        bodySmall: TextStyle(fontSize: 12, color: textGray),

        // Label styles
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textGray,
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: borderGray,
        thickness: 1,
        space: 16,
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: textLight, size: 24),
    );
  }

  /// Returns color based on assignment priority
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
        return priorityLow;
      default:
        return priorityMedium;
    }
  }

  /// Returns color based on attendance percentage
  static Color getAttendanceColor(double percentage) {
    if (percentage >= 85) {
      return excellentAttendance;
    } else if (percentage >= 75) {
      return goodAttendance;
    } else {
      return atRiskAttendance;
    }
  }

  /// Returns color based on session type
  static Color getSessionTypeColor(String sessionType) {
    switch (sessionType.toLowerCase()) {
      case 'class':
        return const Color(0xFF3B82F6); // Blue
      case 'mastery session':
        return const Color(0xFF8B5CF6); // Purple
      case 'study group':
        return const Color(0xFF10B981); // Green
      case 'psl meeting':
        return const Color(0xFFF59E0B); // Orange
      default:
        return darkBlue;
    }
  }

  /// Custom box decoration for cards with gradient
  static BoxDecoration cardDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? darkBlue,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Custom box decoration for warning cards
  static BoxDecoration warningCardDecoration() {
    return BoxDecoration(
      color: warningRed.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: warningRed, width: 2),
    );
  }

  /// Custom box decoration for success cards
  static BoxDecoration successCardDecoration() {
    return BoxDecoration(
      color: successGreen.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: successGreen, width: 2),
    );
  }
}
