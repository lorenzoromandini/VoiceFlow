import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// E-Reader inspired theme for VoiceFlow Notes
/// Warm, paper-like backgrounds with ink-like text colors
/// Designed for comfortable long-form reading and writing
class AppTheme {
  // E-Reader Colors - Light Mode (Cream Paper)
  static const Color _creamPaper = Color(0xFFF5F0E6);          // Main background
  static const Color _lightPaper = Color(0xFFFAF7F0);         // Cards, surfaces
  static const Color _whitePaper = Color(0xFFFFFFFF);        // Elevated surfaces
  static const Color _sepiaInk = Color(0xFF2C2416);           // Primary text (ink)
  static const Color _pencilGray = Color(0xFF6B6560);          // Secondary text
  static const Color _paperFold = Color(0xFFE8E2D9);          // Dividers, borders
  static const Color _purpleInk = Color(0xFF5C5578);          // Primary accent
  static const Color _tealInk = Color(0xFF7A9E9F);            // Secondary accent
  static const Color _brownInk = Color(0xFF8B7355);           // Tertiary accent

  // E-Reader Colors - Dark Mode (Midnight Ink)
  static const Color _sepiaDark = Color(0xFF2D2A26);          // Main background
  static const Color _elevatedSepia = Color(0xFF3D3830);      // Cards, surfaces
  static const Color _cardSepia = Color(0xFF454038);          // Elevated surfaces
  static const Color _candlelight = Color(0xFFE8E4DC);         // Primary text
  static const Color _mutedLight = Color(0xFFA8A49C);          // Secondary text
  static const Color _pageEdge = Color(0xFF4A453C);           // Dividers, borders
  static const Color _lavenderGlow = Color(0xFF8B85A8);         // Primary accent
  static const Color _tealGlow = Color(0xFF9BC5C6);            // Secondary accent
  static const Color _beigeGlow = Color(0xFFB8A896);            // Tertiary accent

  // Typography
  static const String _uiFont = 'Poppins';
  static const String _contentFont = 'Merriweather';

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: _purpleInk,
        onPrimary: _whitePaper,
        primaryContainer: _lightPaper,
        onPrimaryContainer: _purpleInk,
        secondary: _tealInk,
        onSecondary: _whitePaper,
        secondaryContainer: _lightPaper,
        onSecondaryContainer: _tealInk,
        tertiary: _brownInk,
        onTertiary: _whitePaper,
        tertiaryContainer: _lightPaper,
        onTertiaryContainer: _brownInk,
        error: const Color(0xFFB3261E),
        onError: _whitePaper,
        errorContainer: const Color(0xFFF9DEDC),
        onErrorContainer: const Color(0xFF601410),
        surface: _lightPaper,
        onSurface: _sepiaInk,
        surfaceContainerHighest: _creamPaper,
        onSurfaceVariant: _pencilGray,
        outline: _paperFold,
        outlineVariant: _paperFold,
        shadow: _sepiaInk.withOpacity(0.1),
        scrim: _sepiaInk.withOpacity(0.5),
        inverseSurface: _sepiaDark,
        onInverseSurface: _candlelight,
        inversePrimary: _lavenderGlow,
        surfaceTint: _purpleInk,
      ),
      scaffoldBackgroundColor: _creamPaper,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _creamPaper,
        foregroundColor: _sepiaInk,
        titleTextStyle: _uiTextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _sepiaInk,
        ),
      ),
      textTheme: _buildTextTheme(Brightness.light),
      cardTheme: CardTheme(
        elevation: 1,
        color: _whitePaper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _paperFold,
            width: 1,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _purpleInk,
        foregroundColor: _whitePaper,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightPaper,
        selectedItemColor: _purpleInk,
        unselectedItemColor: _pencilGray,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _whitePaper,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _paperFold, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _purpleInk, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: _uiTextStyle(color: _pencilGray),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _purpleInk,
          foregroundColor: _whitePaper,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: _paperFold,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: _lightPaper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _sepiaInk,
        contentTextStyle: _uiTextStyle(color: _candlelight),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _purpleInk;
          }
          return _pencilGray;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _purpleInk.withOpacity(0.5);
          }
          return _paperFold;
        }),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: _lavenderGlow,
        onPrimary: _sepiaDark,
        primaryContainer: _elevatedSepia,
        onPrimaryContainer: _lavenderGlow,
        secondary: _tealGlow,
        onSecondary: _sepiaDark,
        secondaryContainer: _elevatedSepia,
        onSecondaryContainer: _tealGlow,
        tertiary: _beigeGlow,
        onTertiary: _sepiaDark,
        tertiaryContainer: _elevatedSepia,
        onTertiaryContainer: _beigeGlow,
        error: const Color(0xFFF2B8B5),
        onError: const Color(0xFF601410),
        errorContainer: const Color(0xFF8C1D18),
        onErrorContainer: const Color(0xFFF9DEDC),
        surface: _elevatedSepia,
        onSurface: _candlelight,
        surfaceContainerHighest: _sepiaDark,
        onSurfaceVariant: _mutedLight,
        outline: _pageEdge,
        outlineVariant: _pageEdge,
        shadow: Colors.black.withOpacity(0.3),
        scrim: Colors.black.withOpacity(0.6),
        inverseSurface: _creamPaper,
        onInverseSurface: _sepiaInk,
        inversePrimary: _purpleInk,
        surfaceTint: _lavenderGlow,
      ),
      scaffoldBackgroundColor: _sepiaDark,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _sepiaDark,
        foregroundColor: _candlelight,
        titleTextStyle: _uiTextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _candlelight,
        ),
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      cardTheme: CardTheme(
        elevation: 1,
        color: _cardSepia,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _pageEdge,
            width: 1,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _lavenderGlow,
        foregroundColor: _sepiaDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _elevatedSepia,
        selectedItemColor: _lavenderGlow,
        unselectedItemColor: _mutedLight,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _cardSepia,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _pageEdge, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lavenderGlow, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: _uiTextStyle(color: _mutedLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lavenderGlow,
          foregroundColor: _sepiaDark,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: _pageEdge,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: _elevatedSepia,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _candlelight,
        contentTextStyle: _uiTextStyle(color: _sepiaDark),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _lavenderGlow;
          }
          return _mutedLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _lavenderGlow.withOpacity(0.5);
          }
          return _pageEdge;
        }),
      ),
    );
  }

  /// UI text style (Poppins for buttons, nav, etc.)
  static TextStyle _uiTextStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    required Color color,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  /// Content text style (Merriweather for notes, reading)
  static TextStyle _contentTextStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    required Color color,
    double height = 1.6,
  }) {
    return GoogleFonts.merriweather(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primaryColor = isDark ? _candlelight : _sepiaInk;
    final secondaryColor = isDark ? _mutedLight : _pencilGray;

    return TextTheme(
      // Display - Large titles
      displayLarge: _uiTextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      displayMedium: _uiTextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      displaySmall: _uiTextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),

      // Headlines - Section titles
      headlineLarge: _uiTextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      headlineMedium: _uiTextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      headlineSmall: _uiTextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),

      // Titles - Card titles, list items
      titleLarge: _uiTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleMedium: _uiTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleSmall: _uiTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),

      // Body - Main content (using Merriweather for reading comfort)
      bodyLarge: _contentTextStyle(
        fontSize: 18,
        color: primaryColor,
      ),
      bodyMedium: _contentTextStyle(
        fontSize: 16,
        color: primaryColor,
      ),
      bodySmall: _contentTextStyle(
        fontSize: 14,
        color: secondaryColor,
      ),

      // Labels - Buttons, captions
      labelLarge: _uiTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      labelMedium: _uiTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
      labelSmall: _uiTextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
    );
  }

  /// Helper to get content text style for notes
  static TextStyle noteTitleStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _uiTextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: isDark ? _candlelight : _sepiaInk,
    );
  }

  static TextStyle noteContentStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _contentTextStyle(
      fontSize: 16,
      color: isDark ? _candlelight : _sepiaInk,
      height: 1.6,
    );
  }

  static TextStyle notePreviewStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _contentTextStyle(
      fontSize: 14,
      color: isDark ? _mutedLight : _pencilGray,
      height: 1.5,
    );
  }
}
