import 'dart:convert'; // ใช้แปลงข้อมูล JSON ที่ได้จาก API เป็น List
import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http; // ใช้เรียกข้อมูลจาก API
import 'favorites_screen.dart'; 
import 'recipe_detail_screen.dart'; 

// ใช้ StatefulWidget เพราะข้อมูลบนหน้าเช่นเมนูหรือรายการโปรดสามารถเปลี่ยนแปลงได้
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> recipes = []; // รายการเมนูทั้งหมดที่โหลดมาจาก API
  Set<String> favoriteIds = {}; // เก็บ id ของเมนูที่ผู้ใช้กด Favorite
  String selectedCategory = "All"; // หมวดหมู่ที่เลือก (ค่าเริ่มต้นคือ All)

  @override
  void initState() {
    super.initState();
    loadRecipes(); // โหลดเมนูทั้งหมด
    loadFavorites(); // โหลดรายการโปรด
  }

  // เรียก API เพื่อโหลดเมนูทั้งหมด
  Future<void> loadRecipes() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/recipes'));
    if (response.statusCode == 200) {
      setState(() {
        recipes = json.decode(response.body); // แปลง JSON เป็น List แล้วเก็บไว้
      });
    }
  }

  // โหลดรายการโปรดจาก API เพื่อแสดงสถานะหัวใจ
  Future<void> loadFavorites() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/favorites'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        // ใช้ Set เพื่อให้เช็กว่าชอบเมนูไหนเร็ว และไม่ซ้ำ
        favoriteIds = (data as List).map<String>((item) => item["id"].toString()).toSet();
      });
    }
  }

  // ฟังก์ชันกดหัวใจ เพิ่มหรือลบจากรายการโปรด
  Future<void> toggleFavorite(Map<String, dynamic> recipe) async {
    final id = recipe["id"].toString();
    final isFavorite = favoriteIds.contains(id); // เช็กว่าเมนูนี้กดชอบไว้หรือยัง

    if (isFavorite) {
      // ถ้าเคยกดชอบแล้ว → ลบออกจาก favorites
      await http.delete(Uri.parse('http://10.0.2.2:3000/favorites/$id'));
      setState(() => favoriteIds.remove(id));
    } else {
      // ถ้ายังไม่เคยกดชอบ → เพิ่มเข้า favorites
      final res = await http.get(Uri.parse('http://10.0.2.2:3000/favorites/$id'));
      if (res.statusCode == 404) {
        await http.post(
          Uri.parse('http://10.0.2.2:3000/favorites'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(recipe), // ส่งข้อมูลเมนูทั้งก้อนไปเก็บใน favorites
        );
        setState(() => favoriteIds.add(id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ["All", "Food", "Dessert", "Drink"]; // หมวดหมู่ที่มีให้เลือก
    final filtered = recipes.where((r) => selectedCategory == "All" || r["type"] == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Delicious", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
      ),
      drawer: Drawer( // เมนูด้านข้าง
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.redAccent),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile( // ปุ่ม All Recipes
              leading: const Icon(Icons.menu_book),
              title: const Text("All Recipes"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile( // ปุ่ม Favorites
              leading: const Icon(Icons.favorite),
              title: const Text("Favorites"),
              onTap: () async {
                Navigator.pop(context); // ปิด Drawer ก่อน
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()), // ไปหน้า Favorites
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16), // เว้นขอบซ้ายขวา
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Easy to cook menu", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder( // แสดงหมวดหมู่แนวนอน
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (_, index) {
                  final category = categories[index];
                  final selected = category == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip( // ปุ่มเลือกหมวดหมู่ กดแล้วเปลี่ยนสี
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
              child: GridView.builder( // แสดงเมนูอาหารเป็นตาราง
                itemCount: filtered.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // แถวละ 2 ช่อง
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final recipe = filtered[index];
                  final isFavorite = favoriteIds.contains(recipe["id"].toString());

                  return GestureDetector( // คลิกเพื่อไปหน้าแสดงรายละเอียดเมนู
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
                    ),
                    child: Container(
                      decoration: BoxDecoration( // สร้างกรอบเมนูให้ดูสวย
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
                            child: IconButton( // ปุ่มกด Favorite (หัวใจ)
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => toggleFavorite(recipe),
                            ),
                          ),
                          Image.network(recipe["image"], height: 90), // รูปเมนู
                          const SizedBox(height: 8),
                          Text(
                            recipe["name"], // ชื่อเมนู
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recipe["time"], // เวลาเตรียมอาหาร
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
