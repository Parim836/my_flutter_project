import 'dart:convert'; 
import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http; 
import 'recipe_detail_screen.dart';

// สร้างหน้า Favorites เป็น StatefulWidget เพราะต้องโหลดข้อมูลใหม่ได้
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<dynamic>> _favoritesFuture; // ตัวแปรสำหรับเก็บข้อมูลที่รอโหลด (Future)

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _fetchFavorites(); // โหลดรายการโปรดตอนเปิดหน้านี้ครั้งแรก
  }

  // ดึงข้อมูลเมนูโปรดจาก API
  Future<List<dynamic>> _fetchFavorites() async {
    final url = Uri.parse('http://10.0.2.2:3000/favorites'); // URL API
    final response = await http.get(url); // เรียก API แบบ GET

    if (response.statusCode == 200) {
      // ถ้าสำเร็จ → แปลง JSON เป็น List แล้วส่งออก
      return jsonDecode(response.body);
    } else {
      // ถ้าโหลดไม่สำเร็จ → แจ้ง error
      throw Exception('ไม่สามารถโหลดรายการโปรดได้ (${response.statusCode})');
    }
  }

  // รีเฟรชรายการโปรด (เช่น หลังจากลบเมนู)
  Future<void> _refreshFavorites() async {
    setState(() {
      _favoritesFuture = _fetchFavorites(); // โหลดข้อมูลใหม่อีกครั้ง
    });
  }

  // ลบเมนูออกจากรายการโปรด
  Future<void> _removeFromFavorites(dynamic id) async {
    final url = Uri.parse('http://10.0.2.2:3000/favorites/$id'); // ลบเมนูตาม ID
    final response = await http.delete(url); // ส่ง DELETE ไปยัง API

    if (response.statusCode == 200 || response.statusCode == 204) {
      // ถ้าลบสำเร็จ → แสดง SnackBar แจ้งผู้ใช้
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลบเมนูออกจากรายการโปรดแล้ว')),
      );
      _refreshFavorites(); // โหลดข้อมูลใหม่เพื่ออัปเดตหน้าจอ
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')), // แถบหัวของหน้า
      body: FutureBuilder<List<dynamic>>( // ใช้โหลดข้อมูล
        future: _favoritesFuture, // ตัวแปรที่โหลดข้อมูล
        builder: (context, snapshot) {
          // กรณียังโหลดไม่เสร็จจะแสดงวงกลมหมุน
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // กรณีโหลดสำเร็จ แต่ไม่มีรายการโปรดเลย
          if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No Favorites'));
          }

          // กรณีโหลดสำเร็จและมีข้อมูล
          if (snapshot.hasData) {
            final recipes = snapshot.data!; // ดึงรายการเมนูโปรดมาเก็บไว้
            return ListView.builder( // แสดงรายการแบบเลื่อนลง
              itemCount: recipes.length, // จำนวนรายการ
              itemBuilder: (context, index) {
                final recipe = recipes[index]; // เมนูแต่ละรายการ
                return _buildFavoriteItem(recipe); // สร้างกล่องรายการแต่ละอัน
              },
            );
          }

          // กรณีเกิด error หรือโหลดข้อมูลไม่ได้
          return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
        },
      ),
    );
  }

  // ฟังก์ชันสำหรับแสดงรายการเมนูโปรด 1 อัน (แบบ ListTile)
  Widget _buildFavoriteItem(dynamic recipe) {
    return ListTile(
      leading: Image.network( // แสดงรูปภาพเมนู
        recipe['image'],
        width: 50,
        height: 50,
        fit: BoxFit.cover, // ขนาดพอดีกับกล่อง
      ),
      title: Text(recipe['name']), // ชื่อเมนู
      subtitle: Text(recipe['time']), // เวลาทำอาหาร
      trailing: IconButton( // ปุ่มลบ (อยู่ด้านขวา)
        icon: const Icon(Icons.delete, color: Colors.redAccent),
        onPressed: () => _removeFromFavorites(recipe['id']), // กดแล้วลบเมนูออกจากรายการโปรด
      ),
      onTap: () {// กดเมนูเพื่อไปหน้าแสดงรายละเอียด
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
