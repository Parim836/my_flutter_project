import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'favorites_screen.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> recipes = [];
  Set<String> favoriteIds = {};
  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    loadRecipes();
    loadFavorites();
  }

  Future<void> loadRecipes() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/recipes'));
    if (response.statusCode == 200) {
      setState(() {
        recipes = json.decode(response.body);
      });
    }
  }

  Future<void> loadFavorites() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/favorites'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        favoriteIds = (data as List).map<String>((item) => item["id"].toString()).toSet();
      });
    }
  }

  Future<void> toggleFavorite(Map<String, dynamic> recipe) async {
    final id = recipe["id"].toString();
    final isFavorite = favoriteIds.contains(id);

    if (isFavorite) {
      await http.delete(Uri.parse('http://10.0.2.2:3000/favorites/$id'));
      setState(() => favoriteIds.remove(id));
    } else {
      final res = await http.get(Uri.parse('http://10.0.2.2:3000/favorites/$id'));
      if (res.statusCode == 404) {
        await http.post(
          Uri.parse('http://10.0.2.2:3000/favorites'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(recipe),
        );
        setState(() => favoriteIds.add(id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ["All", "Food", "Dessert", "Drink"];
    final filtered = recipes.where((r) => selectedCategory == "All" || r["type"] == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Delicious", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.redAccent),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text("All Recipes"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("Favorites"),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Easy to cook menu", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (_, index) {
                  final category = categories[index];
                  final selected = category == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      selectedColor: Colors.redAccent,
                      onSelected: (_) => setState(() => selectedCategory = category),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text("Popular", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                itemCount: filtered.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final recipe = filtered[index];
                  final isFavorite = favoriteIds.contains(recipe["id"].toString());

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => toggleFavorite(recipe),
                            ),
                          ),
                          Image.network(recipe["image"], height: 90),
                          const SizedBox(height: 8),
                          Text(
                            recipe["name"],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recipe["time"],
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
