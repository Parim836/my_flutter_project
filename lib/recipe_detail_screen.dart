import 'package:flutter/material.dart'; 
// สร้างหน้ารายละเอียดเมนูอาหารแบบ Stateless เพราะข้อมูลไม่ได้เปลี่ยนแปลง
class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe; // รับข้อมูลเมนูที่ถูกส่งมาจากหน้าอื่น

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ดึงส่วนผสมจากเมนู ถ้าไม่มีให้ใช้ List ว่าง
    final ingredients = recipe['ingredients'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 255, 255, 255)),

      // ทำให้เนื้อหาทั้งหน้าเลื่อนได้
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16), // เว้นขอบรอบจอ
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // จัดชิดซ้าย
          children: [

            // แสดงรูปภาพเมนู อยู่กลางจอ
            Center(
              child: ClipRRect( // ทำให้รูปมีมุมมน
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  recipe['image'], // โหลดภาพจาก URL ที่ส่งมา
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover, // ครอบภาพให้เต็มโดยไม่ยืด
                ),
              ),
            ),
            const SizedBox(height: 12), // เว้นระยะห่างด้านล่าง
            Center(
              child: Text(
                recipe['name'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.grey),
                const SizedBox(width: 8), // เว้นระยะห่างจากไอคอน
                Text(
                  recipe['time'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              "Ingredients",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // ตารางแสดงวัตถุดิบ โดยไม่ให้เลื่อนในตัว
            GridView.builder(
              shrinkWrap: true, // ย่อให้พอดีกับเนื้อหา
              physics: const NeverScrollableScrollPhysics(), // ปิดการเลื่อนนี้
              itemCount: ingredients.length, // จำนวนวัตถุดิบ
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 ช่องต่อแถว
                crossAxisSpacing: 12, // ระยะห่างแนวนอน
                mainAxisSpacing: 12, // ระยะห่างแนวตั้ง
                childAspectRatio: 0.8, // สัดส่วนความกว้าง:สูง
              ),
              itemBuilder: (_, index) {
                final item = ingredients[index]; // วัตถุดิบแต่ละชิ้น
                final name = item['name'] ?? ''; // ชื่อวัตถุดิบ
                final image = item['image'] ?? ''; // รูปวัตถุดิบ

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16), // มุมโค้ง
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300), // ขอบสีเทาอ่อน
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2), // เงาด้านล่าง
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8), // เว้นขอบด้านในกล่อง
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // จัดกลางในแนวตั้ง
                    children: [
                      // แสดงรูปวัตถุดิบ
                      SizedBox(
                        height: 60,
                        child: Image.network(
                          image,
                          fit: BoxFit.contain, // ปรับขนาดภาพให้ไม่โดนตัด
                        ),
                      ),

                      const SizedBox(height: 8), 

                      // แสดงชื่อวัตถุดิบแบบจัดกลาง
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
