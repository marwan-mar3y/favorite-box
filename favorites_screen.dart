import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/post.dart';
import '../services/favorites_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  final FavoritesService _favoritesService = const FavoritesService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: ValueListenableBuilder<Box<Post>>(
        valueListenable: _favoritesService.listenable(),
        builder: (context, box, _) {
          final favorites = _favoritesService.getFavorites();

          if (favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No favorites yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final post = favorites[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 4,
                ),
                child: ListTile(
                  title: Text(
                    post.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(post.body),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.star, color: Colors.amber),
                    tooltip: 'Remove from favorites',
                    onPressed: () => _favoritesService.toggleFavorite(post),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
