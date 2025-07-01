import 'package:flutter/material.dart';

class AppConstants {
  // Couleurs de l'application
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color accentColor = Color(0xFFFF4081);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFB00020);
  
  // Couleurs mode sombre
  static const Color darkPrimaryColor = Color(0xFF1976D2);
  static const Color darkSecondaryColor = Color(0xFF00BCD4);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkErrorColor = Color(0xFFCF6679);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF03DAC6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1976D2), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Dimensions
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  
  // Durées d'animation
  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  
  // Textes
  static const String appName = 'Météo HD';
  static const String appDescription = 'Application météo moderne et intuitive';
  static const String welcomeMessage = 'Bienvenue dans votre application météo personnalisée !';
  static const String startButtonText = 'Commencer l\'expérience';
  static const String restartButtonText = 'Recommencer';
  static const String backButtonText = 'Retour';
  static const String errorTitle = 'Erreur';
  static const String retryButtonText = 'Réessayer';
  static const String okButtonText = 'OK';
  
  // Messages d'erreur
  static const String networkError = 'Erreur de connexion réseau';
  static const String apiError = 'Erreur lors de la récupération des données';
  static const String locationError = 'Erreur de localisation';
  static const String unknownError = 'Une erreur inconnue s\'est produite';
  
  // Villes par défaut
  static const List<String> defaultCities = [
    'Paris',
    'New York',
    'Tokyo',
    'London',
    'Sydney',
  ];
}

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppConstants.primaryColor,
      secondary: AppConstants.secondaryColor,
      surface: Color(0xFFFAFAFA),
      surfaceContainerHighest: Color(0xFFF5F5F5),
      error: AppConstants.errorColor,
      onSurface: Colors.black,
      onSurfaceVariant: Color(0xFF666666),
    ),
    fontFamily: null,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppConstants.darkPrimaryColor,
      secondary: AppConstants.darkSecondaryColor,
      surface: Color(0xFF121212),
      surfaceContainerHighest: Color(0xFF1E1E1E),
      error: AppConstants.darkErrorColor,
      onSurface: Colors.white,
      onSurfaceVariant: Color(0xFFB3B3B3),
    ),
    fontFamily: null,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppConstants.darkPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.darkPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
    ),
  );
} 