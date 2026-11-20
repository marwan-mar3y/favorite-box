import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/post.dart';

class FavoritesService {
  const FavoritesService();

  static const String _boxName = 'favoritesBox';

  Box<Post> get _box => Hive.box<Post>(_boxName);

  /// Toggles favorite status for [post] using post.id as the Hive key.
  /// Stores a fresh copy so Hive does not throw a duplicate-box HiveObject error.
  Future<void> toggleFavorite(Post post) async {
    if (_box.containsKey(post.id)) {
      await _box.delete(post.id);
    } else {
      final copy = Post(
        id: post.id,
        title: post.title,
        body: post.body,
        userId: post.userId,
      );
      await _box.put(post.id, copy);
    }
  }

  /// Synchronously checks whether a post with [id] is in favoritesBox.
  bool isFavorite(int id) {
    return _box.containsKey(id);
  }

  /// Synchronously returns all saved favorite posts.
  List<Post> getFavorites() {
    return _box.values.toList();
  }

  /// Returns a ValueListenable for reactive UI updates on favoritesBox changes.
  ValueListenable<Box<Post>> listenable() {
    return _box.listenable();
  }
}
