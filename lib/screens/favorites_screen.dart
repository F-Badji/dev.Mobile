import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Favoris'),
        centerTitle: true,
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text(
                'Aucune ville favorite',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final city = favorites[index];
                return Card(
                  color: Colors.white.withAlpha(26),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      city,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        context.read<FavoritesProvider>().removeFavorite(city);
                      },
                    ),
                    onTap: () {
                      // TODO: Naviguer vers la météo de la ville
                    },
                  ),
                );
              },
            ),
    );
  }
} 