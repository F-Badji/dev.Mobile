import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  static const String _prefsKey = 'favorite_cities';
  List<String> _favorites = [];

  List<String> get favorites => _favorites;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favorites = prefs.getStringList(_prefsKey) ?? [];
    notifyListeners();
  }

  Future<void> addFavorite(String city) async {
    if (!_favorites.contains(city)) {
      _favorites.add(city);
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList(_prefsKey, _favorites);
    }
  }

  Future<void> removeFavorite(String city) async {
    _favorites.remove(city);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_prefsKey, _favorites);
  }

  bool isFavorite(String city) => _favorites.contains(city);
} 