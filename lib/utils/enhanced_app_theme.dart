import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnhancedAppTheme {
  // Professional color palette
  static const Color primaryTeal = Color(0xFF006064);
  static const Color primaryTealLight = Color(0xFF4F9A94);
  static const Color primaryTealDark = Color(0xFF00363A);
  
  static const Color secondaryAmber = Color(0xFFFF8F00);
  static const Color secondaryAmberLight = Color(0xFFFFBF47);
  static const Color secondaryAmberDark = Color(0xFFC56000);
  
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentGreenLight = Color(0xFF81C784);
  static const Color accentGreenDark = Color(0xFF2E7D32);
  
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color infoBlue = Color(0xFF2196F3);

  // Typography system
  static const String fontFamily = 'Roboto';
  
  // Light theme
  static ThemeData get lightTheme {
    const ColorScheme colorScheme = ColorScheme.light(
      primary: primaryTeal,
      onPrimary: Colors.white,
      primaryContainer: primaryTealLight,
      onPrimaryContainer: primaryTealDark,
      secondary: secondaryAmber,
      onSecondary: Colors.white,
      secondaryContainer: secondaryAmberLight,
      onSecondaryContainer: secondaryAmberDark,
      tertiary: accentGreen,
      onTertiary: Colors.white,
      error: errorRed,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF1C1B1F),
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: Color(0xFF49454F),
      outline: Color(0xFF79747E),
      outlineVariant: Color(0xFFCAC4D0),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: primaryTealLight,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      
      // App bar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 4,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(0),
        clipBehavior: Clip.antiAlias,
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.15),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
        ),
      ),
      
      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outline),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
        ),
      ),
      
      // Filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
          fontFamily: fontFamily,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontFamily: fontFamily,
        ),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: fontFamily,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        pressElevation: 2,
      ),
      
      // Navigation bar theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              fontFamily: fontFamily,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
            fontFamily: fontFamily,
          );
        }),
      ),
      
      // Navigation rail theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
          fontFamily: fontFamily,
        ),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: fontFamily,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
          fontFamily: fontFamily,
        ),
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      
      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
          fontFamily: fontFamily,
        ),
      ),
      
      // Snack bar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onInverseSurface,
          fontFamily: fontFamily,
        ),
        actionTextColor: colorScheme.inversePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      
      // Text theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: colorScheme.onSurfaceVariant,
          fontFamily: fontFamily,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    const ColorScheme colorScheme = ColorScheme.dark(
      primary: primaryTealLight,
      onPrimary: primaryTealDark,
      primaryContainer: primaryTealDark,
      onPrimaryContainer: primaryTealLight,
      secondary: secondaryAmberLight,
      onSecondary: secondaryAmberDark,
      secondaryContainer: secondaryAmberDark,
      onSecondaryContainer: secondaryAmberLight,
      tertiary: accentGreenLight,
      onTertiary: accentGreenDark,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      surface: Color(0xFF1C1B1F),
      onSurface: Color(0xFFE6E1E5),
      surfaceContainerHighest: Color(0xFF36343B),
      onSurfaceVariant: Color(0xFFCAC4D0),
      outline: Color(0xFF938F99),
      outlineVariant: Color(0xFF49454F),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFFE6E1E5),
      onInverseSurface: Color(0xFF313033),
      inversePrimary: primaryTeal,
      brightness: Brightness.dark,
    );

    return lightTheme.copyWith(
      colorScheme: colorScheme,
      appBarTheme: lightTheme.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          fontFamily: fontFamily,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: lightTheme.cardTheme.copyWith(
        color: colorScheme.surface,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        elevation: 2,
      ),
      inputDecorationTheme: lightTheme.inputDecorationTheme.copyWith(
        fillColor: colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
          fontFamily: fontFamily,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontFamily: fontFamily,
        ),
      ),
      snackBarTheme: lightTheme.snackBarTheme.copyWith(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onInverseSurface,
          fontFamily: fontFamily,
        ),
      ),
    );
  }

  // Custom colors for specific use cases
  static const Map<String, Color> customColors = {
    'ayurvedic': accentGreen,
    'allopathic': infoBlue,
    'other': Color(0xFF9E9E9E),
    'male': infoBlue,
    'female': Color(0xFFE91E63),
    'success': successGreen,
    'warning': warningOrange,
    'error': errorRed,
    'info': infoBlue,
  };

  // Spacing system
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border radius system
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;

  // Elevation system
  static const double elevationXS = 1.0;
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 12.0;
  static const double elevationXXL = 16.0;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Helper methods
  static Color getMedicineTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'ayurvedic':
        return customColors['ayurvedic']!;
      case 'allopathic':
        return customColors['allopathic']!;
      default:
        return customColors['other']!;
    }
  }

  static Color getGenderColor(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return customColors['male']!;
      case 'female':
        return customColors['female']!;
      default:
        return customColors['other']!;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'active':
        return customColors['success']!;
      case 'warning':
      case 'pending':
        return customColors['warning']!;
      case 'error':
      case 'failed':
      case 'inactive':
        return customColors['error']!;
      case 'info':
      case 'draft':
        return customColors['info']!;
      default:
        return customColors['other']!;
    }
  }

  // Gradient helpers
  static LinearGradient getPrimaryGradient() {
    return const LinearGradient(
      colors: [primaryTeal, primaryTealLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getSecondaryGradient() {
    return const LinearGradient(
      colors: [secondaryAmber, secondaryAmberLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getSuccessGradient() {
    return const LinearGradient(
      colors: [accentGreen, accentGreenLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Shadow helpers
  static List<BoxShadow> getElevationShadow(double elevation) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: elevation,
        offset: Offset(0, elevation / 2),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
    ];
  }
}

