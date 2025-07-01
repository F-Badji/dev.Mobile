import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/weather_model.dart';
import '../utils/constants.dart';
import '../widgets/lottie_weather_icon.dart';

class CityDetailScreen extends StatefulWidget {
  final WeatherModel weather;

  const CityDetailScreen({
    super.key,
    required this.weather,
  });

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen>
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    // Démarrer les animations
    _fadeController.forward();
    _slideController.forward();
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
      body: Container(
        decoration: BoxDecoration(
          gradient: AppConstants.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar personnalisée
              _buildAppBar(),
              
              // Contenu principal
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: Column(
                        children: [
                          // En-tête de la ville
                          _buildCityHeader(),
                          
                          const SizedBox(height: AppConstants.paddingLarge),
                          
                          // Carte Google Maps
                          _buildMap(),
                          
                          const SizedBox(height: AppConstants.paddingLarge),
                          
                          // Informations météo détaillées
                          _buildWeatherDetails(),
                          
                          const SizedBox(height: AppConstants.paddingLarge),
                          
                          // Bouton pour ouvrir dans Google Maps
                          _buildOpenInMapsButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
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
              widget.weather.city,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Pour équilibrer l'appBar
        ],
      ),
    );
  }

  Widget _buildCityHeader() {
    return Container(
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
          // Icône météo animée
          LottieWeatherIcon(weatherDescription: widget.weather.description, size: 80),
          
          const SizedBox(height: AppConstants.paddingMedium),
          
          // Température
          Text(
            '${widget.weather.temperature.round()}°C',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          
          // Description
          Text(
            widget.weather.description,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppConstants.paddingMedium),
          
          // Température ressentie
          Text(
            'Ressenti: ${widget.weather.feelsLike.round()}°C',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.weather.latitude, widget.weather.longitude),
            zoom: 12,
          ),
          onMapCreated: (GoogleMapController controller) {
            // Controller non utilisé pour l'instant
          },
          markers: {
            Marker(
              markerId: MarkerId(widget.weather.city),
              position: LatLng(widget.weather.latitude, widget.weather.longitude),
              infoWindow: InfoWindow(
                title: widget.weather.city,
                snippet: '${widget.weather.temperature.round()}°C - ${widget.weather.description}',
              ),
            ),
          },
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }

  Widget _buildWeatherDetails() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Détails météorologiques',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          
          const SizedBox(height: AppConstants.paddingLarge),
          
          _buildDetailRow('Humidité', '${widget.weather.humidity}%', Icons.water_drop_rounded),
          _buildDetailRow('Vent', '${widget.weather.windSpeed} km/h ${widget.weather.windDirection}', Icons.air_rounded),
          _buildDetailRow('Pression', '${widget.weather.pressure} hPa', Icons.speed_rounded),
          _buildDetailRow('Visibilité', '${widget.weather.visibility / 1000} km', Icons.visibility_rounded),
          _buildDetailRow('Coordonnées', '${widget.weather.latitude.toStringAsFixed(4)}, ${widget.weather.longitude.toStringAsFixed(4)}', Icons.location_on_rounded),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenInMapsButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => _openInGoogleMaps(),
        icon: const Icon(Icons.map_rounded, size: 20),
        label: const Text(
          'Ouvrir dans Google Maps',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppConstants.primaryColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
      ),
    );
  }

  void _openInGoogleMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${widget.weather.latitude},${widget.weather.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir Google Maps'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }
} 