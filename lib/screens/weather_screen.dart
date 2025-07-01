import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../utils/constants.dart';
import '../widgets/progress_gauge.dart';
import '../widgets/weather_card.dart';
import '../widgets/error_widget.dart';
import 'city_detail_screen.dart';
import '../widgets/animated_weather_background.dart';
import '../widgets/confetti_success.dart';
import '../widgets/shimmer_weather_card.dart';
import '../widgets/lottie_weather_icon.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import '../widgets/particle_system.dart';

class WeatherScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? cityName;

  const WeatherScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.cityName,
  });

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: AppConstants.animationDurationSlow,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: AppConstants.animationDurationNormal,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    // Démarrer l'expérience météo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().startWeatherExperience();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          // Déterminer la condition météo dominante (par défaut 'clear')
          String mainCondition = 'clear';
          if (weatherProvider.weatherData.isNotEmpty) {
            mainCondition = weatherProvider.weatherData.first.description.toLowerCase().contains('pluie')
                ? 'rain'
                : weatherProvider.weatherData.first.description.toLowerCase().contains('neige')
                    ? 'snow'
                    : weatherProvider.weatherData.first.description.toLowerCase().contains('orage')
                        ? 'thunder'
                        : weatherProvider.weatherData.first.description.toLowerCase().contains('nuage')
                            ? 'clouds'
                            : 'clear';
          }

          // Jouer le son météo et retour haptique lors du succès
          if (weatherProvider.isProgressComplete) {
            AudioService().playWeatherSound(mainCondition);
            HapticService().success();
          }

          return Stack(
            children: [
              AnimatedWeatherBackground(
                weatherCondition: mainCondition,
                isDarkMode: weatherProvider.isDarkMode,
              ),
              // Système de particules météo
              ParticleSystem(
                weatherType: mainCondition,
                isActive: true,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    children: [
                      // AppBar personnalisée
                      _buildAppBar(weatherProvider),
                      const SizedBox(height: AppConstants.paddingLarge),
                      // Contenu principal
                      Expanded(
                        child: _buildMainContent(weatherProvider),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(WeatherProvider weatherProvider) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        Expanded(
          child: Text(
            AppConstants.appName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          onPressed: () {
            weatherProvider.toggleTheme();
          },
          icon: Icon(
            weatherProvider.isDarkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(WeatherProvider weatherProvider) {
    if (weatherProvider.errorMessage != null) {
      return CustomErrorWidget(
        message: weatherProvider.errorMessage!,
        onRetry: () {
          weatherProvider.clearError();
          weatherProvider.startWeatherExperience();
        },
      );
    }

    if (weatherProvider.isLoading) {
      return _buildLoadingContent(weatherProvider);
    }

    if (weatherProvider.isProgressComplete) {
      return ConfettiSuccess(
        child: _buildWeatherContent(weatherProvider),
      );
    }

    return const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  }

  Widget _buildLoadingContent(WeatherProvider weatherProvider) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Jauge de progression
          ProgressGauge(
            progress: weatherProvider.progress,
            size: 200,
          ),
          const SizedBox(height: AppConstants.paddingXLarge),
          // Message de chargement
          Container(
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
              children: [
                // Animation météo pendant le chargement
                LottieWeatherIcon(weatherDescription: 'nuage', size: 60),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  weatherProvider.loadingMessage,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          // Shimmer sur les cartes météo en attendant les données
          ...List.generate(3, (index) => const ShimmerWeatherCard()),
        ],
      ),
    );
  }

  Widget _buildWeatherContent(WeatherProvider weatherProvider) {
    // Démarrer les animations
    _fadeController.forward();
    _slideController.forward();
    
    return Column(
      children: [
        // Titre de la section
        FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(26),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Text(
                    'Météo mondiale',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: AppConstants.paddingLarge),
        
        // Liste des villes
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ListView.builder(
                itemCount: weatherProvider.weatherData.length,
                itemBuilder: (context, index) {
                  final weather = weatherProvider.weatherData[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                    child: WeatherCard(
                      weather: weather,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CityDetailScreen(weather: weather),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        // Bouton recommencer
        FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  weatherProvider.restartExperience();
                  _fadeController.reset();
                  _slideController.reset();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppConstants.primaryColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh_rounded, size: 20),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Text(
                      AppConstants.restartButtonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
} 