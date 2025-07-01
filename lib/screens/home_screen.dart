import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../utils/constants.dart';
import 'weather_screen.dart';
import '../widgets/rive_weather_animation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: context.watch<WeatherProvider>().isDarkMode
              ? AppConstants.darkGradient
              : AppConstants.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo et titre
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icône météo animée (Rive)
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: RiveWeatherAnimation(
                          riveFile: 'assets/animations/weather.riv',
                          artboard: 'Main',
                          animation: 'idle',
                          size: 120,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      
                      // Titre de l'application
                      Text(
                        AppConstants.appName,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: AppConstants.paddingMedium),
                      
                      // Description
                      Text(
                        AppConstants.appDescription,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Message d'accueil
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26),
                      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                      border: Border.all(
                        color: Colors.white.withAlpha(77),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.waving_hand_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        Text(
                          AppConstants.welcomeMessage,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppConstants.paddingXLarge),
                
                // Bouton pour commencer
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const WeatherScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            final scale = Tween<double>(begin: 0.8, end: 1.0).animate(
                              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                            );
                            final fade = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
                            return FadeTransition(
                              opacity: fade,
                              child: ScaleTransition(
                                scale: scale,
                                child: child,
                              ),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 700),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppConstants.primaryColor,
                      elevation: 8,
                      shadowColor: Colors.black.withAlpha(77),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded, size: 24),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          AppConstants.startButtonText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppConstants.paddingLarge),
                
                // Bouton pour basculer le thème
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        context.read<WeatherProvider>().toggleTheme();
                      },
                      icon: Icon(
                        context.watch<WeatherProvider>().isDarkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Text(
                      context.watch<WeatherProvider>().isDarkMode
                          ? 'Mode clair'
                          : 'Mode sombre',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 