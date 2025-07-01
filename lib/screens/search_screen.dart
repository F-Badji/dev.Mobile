import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/city_autocomplete_service.dart';
import '../providers/favorites_provider.dart';
import 'weather_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final CityAutocompleteService _autocompleteService = CityAutocompleteService();
  List<CitySuggestion> _suggestions = [];
  bool _isLoading = false;

  void _onSearchChanged(String value) async {
    setState(() {
      _isLoading = true;
    });
    final results = await _autocompleteService.getSuggestions(value);
    setState(() {
      _suggestions = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.read<FavoritesProvider>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Recherche de ville'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher une ville...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withAlpha(26),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.white)),
            if (!_isLoading)
              Expanded(
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final city = _suggestions[index];
                    final isFav = context.watch<FavoritesProvider>().isFavorite(city.name);
                    return Card(
                      color: Colors.white.withAlpha(26),
                      child: ListTile(
                        title: Text('${city.name}, ${city.country}', style: const TextStyle(color: Colors.white)),
                        subtitle: Text('Lat: ${city.lat}, Lon: ${city.lon}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        trailing: IconButton(
                          icon: Icon(
                            isFav ? Icons.star : Icons.star_border,
                            color: isFav ? Colors.amber : Colors.white,
                          ),
                          onPressed: () {
                            if (isFav) {
                              favoritesProvider.removeFavorite(city.name);
                            } else {
                              favoritesProvider.addFavorite(city.name);
                            }
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => WeatherScreen(
                                latitude: city.lat,
                                longitude: city.lon,
                                cityName: city.name,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
} 