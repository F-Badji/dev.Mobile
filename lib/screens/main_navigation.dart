import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'weather_screen.dart';
import 'forecast_screen.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';
import 'social_feed_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // TODO: Passer les coordonnées de la ville sélectionnée ou favorite
  final double _defaultLat = 48.8566;
  final double _defaultLon = 2.3522;
  final String _defaultCity = 'Paris';

  @override
  Widget build(BuildContext context) {
    final screens = [
      const WeatherScreen(),
      ForecastScreen(latitude: _defaultLat, longitude: _defaultLon, cityName: _defaultCity),
      const FavoritesScreen(),
      const SearchScreen(),
      const SocialFeedScreen(),
    ];
    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: AppConstants.primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Aujourd\'hui'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart_rounded), label: 'Prévisions'),
          BottomNavigationBarItem(icon: Icon(Icons.star_rounded), label: 'Favoris'),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Recherche'),
          BottomNavigationBarItem(icon: Icon(Icons.forum_rounded), label: 'Social'),
        ],
      ),
    );
  }
} 