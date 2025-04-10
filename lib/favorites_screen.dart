import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<dynamic>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _fetchFavorites();
  }

  Future<List<dynamic>> _fetchFavorites() async {
    final url = Uri.parse('http://10.0.2.2:3000/favorites');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('ไม่สามารถโหลดรายการโปรดได้ (${response.statusCode})');
    }
  }

  Future<void> _refreshFavorites() async {
    setState(() {
      _favoritesFuture = _fetchFavorites();
    });
  }

  Future<void> _removeFromFavorites(dynamic id) async {
    final url = Uri.parse('http://10.0.2.2:3000/favorites/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200 || response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลบเมนูออกจากรายการโปรดแล้ว')),
      );
      _refreshFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: FutureBuilder<List<dynamic>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No Favorites'));
          }

          if (snapshot.hasData) {
            final recipes = snapshot.data!;
            return ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return _buildFavoriteItem(recipe);
              },
            );
          }
          return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
        },
      ),
    );
  }

  Widget _buildFavoriteItem(dynamic recipe) {
    return ListTile(
      leading: Image.network(
        recipe['image'],
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
      title: Text(recipe['name']),
      subtitle: Text(recipe['time']),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.redAccent),
        onPressed: () => _removeFromFavorites(recipe['id']),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
    );
  }
}
