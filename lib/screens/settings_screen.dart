import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../services/personalization_service.dart';
import '../services/accessibility_service.dart';
import '../services/notification_service.dart';
import '../widgets/home_widget.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _notificationService.initialize();
    await HomeWidgetService.initializeWidget();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Paramètres'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Personnalisation'),
            _buildPersonalizationSettings(),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildSectionTitle('Accessibilité'),
            _buildAccessibilitySettings(),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildSectionTitle('Notifications'),
            _buildNotificationSettings(),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildSectionTitle('Fonctionnalités avancées'),
            _buildAdvancedFeatures(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildPersonalizationSettings() {
    return Consumer<PersonalizationService>(
      builder: (context, personalization, child) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                'Mode sombre',
                personalization.isDarkMode,
                personalization.toggleDarkMode,
                Icons.dark_mode_rounded,
              ),
              _buildSwitchTile(
                'Animations',
                personalization.animationsEnabled,
                personalization.toggleAnimations,
                Icons.animation_rounded,
              ),
              _buildSwitchTile(
                'Sons',
                personalization.soundsEnabled,
                personalization.toggleSounds,
                Icons.volume_up_rounded,
              ),
              _buildSwitchTile(
                'Vibrations',
                personalization.hapticsEnabled,
                personalization.toggleHaptics,
                Icons.vibration_rounded,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              _buildSliderTile(
                'Vitesse des animations',
                personalization.animationSpeed,
                (value) => personalization.setAnimationSpeed(value),
                Icons.speed_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccessibilitySettings() {
    return Consumer<AccessibilityService>(
      builder: (context, accessibility, child) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                'Texte large',
                accessibility.largeText,
                accessibility.toggleLargeText,
                Icons.text_fields_rounded,
              ),
              _buildSwitchTile(
                'Contraste élevé',
                accessibility.highContrast,
                accessibility.toggleHighContrast,
                Icons.contrast_rounded,
              ),
              _buildSwitchTile(
                'Lecteur d\'écran',
                accessibility.screenReader,
                accessibility.toggleScreenReader,
                Icons.accessibility_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Column(
        children: [
          _buildActionTile(
            'Tester les notifications',
            () => _notificationService.showWeatherAlert(
              'Test de notification',
              'Ceci est un test de notification météo',
            ),
            Icons.notifications_rounded,
          ),
          _buildActionTile(
            'Programmer une alerte',
            () => _notificationService.scheduleWeatherAlert(
              'Alerte météo',
              'Pluie prévue dans 2 heures',
              DateTime.now().add(const Duration(hours: 2)),
            ),
            Icons.schedule_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFeatures() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Column(
        children: [
          _buildActionTile(
            'Mode AR Météo',
            () => _showARMode(),
            Icons.camera_alt_rounded,
          ),
          _buildActionTile(
            'Widget écran d\'accueil',
            () => _showWidgetPreview(),
            Icons.widgets_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, VoidCallback onChanged, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Switch(
        value: value,
        onChanged: (_) => onChanged(),
        activeColor: AppConstants.accentColor,
      ),
    );
  }

  Widget _buildSliderTile(String title, double value, ValueChanged<double> onChanged, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Slider(
        value: value,
        min: 0.5,
        max: 2.0,
        divisions: 3,
        onChanged: onChanged,
        activeColor: AppConstants.accentColor,
      ),
    );
  }

  Widget _buildActionTile(String title, VoidCallback onTap, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
      onTap: onTap,
    );
  }

  void _showARMode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mode AR Météo'),
        content: const Text('Cette fonctionnalité nécessite ARCore (Android) ou ARKit (iOS).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showWidgetPreview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Widget écran d\'accueil'),
        content: const Text('Le widget météo sera disponible sur l\'écran d\'accueil de votre téléphone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 