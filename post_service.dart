import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class PostService {
  const PostService();

  static const String _boxName = 'postsBox';
  static const String _apiUrl = 'https://jsonplaceholder.typicode.com/posts';

  Box<Post> get _box => Hive.box<Post>(_boxName);

  /// Fetches posts from the remote API, clears postsBox, and caches fresh posts.
  /// Falls back to locally cached posts when offline.
  Future<List<Post>> getPosts() async {
    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
        final posts = decoded
            .map((item) => Post.fromJson(item as Map<String, dynamic>))
            .toList();

        await _box.clear();
        await _box.addAll(posts);
        return posts;
      }
    } catch (_) {
      // Offline or network error: return cached posts from postsBox.
    }

    return _box.values.toList();
  }
}
