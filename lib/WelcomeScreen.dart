import 'package:flutter/material.dart'; // นำเข้า widget UI พื้นฐานของ Flutter
import 'home_screen.dart'; // นำเข้าไฟล์หน้า Home สำหรับเปลี่ยนหน้าเมื่อกดปุ่ม

// สร้างหน้า WelcomeScreen แบบ StatelessWidget (เพราะข้อมูลไม่เปลี่ยนระหว่างการแสดงผล)
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // กำหนดสีพื้นหลังเป็นสีขาว
      body: SafeArea( // ป้องกันไม่ให้เนื้อหาไปติดรอยบากหรือแถบสถานะของมือถือ
        child: Center( // จัดให้องค์ประกอบทั้งหมดอยู่กลางหน้าจอ
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32), // เว้นขอบซ้ายขวาอย่างละ 32 พิกเซล
            child: Column(
              mainAxisSize: MainAxisSize.min, // ให้ Column มีความสูงเท่าที่จำเป็น (ไม่เต็มจอ)
              children: [
                SizedBox(
                  height: 300, // กล่องสูง 300 สำหรับแสดงภาพ
                  child: Image.network(
                    // แสดงภาพ GIF จากลิงก์ (ใช้แทน animation หรือโลโก้)
                    'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExMGFhNzVvM21hZXI3ODZiZGNlYWk5NXB5M2tvbjIxcjI4Y2pybTNzNSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9cw/YoKaNSoTHog8Y3550r/giphy.gif',
                    fit: BoxFit.contain, // ให้รูปพอดีกับขนาดโดยไม่ถูกตัด
                  ),
                ),
                const SizedBox(height: 24), // เว้นระยะด้านล่างจากรูป
                const Text(
                  "Premium food recipes", // ข้อความสั้น ๆ แนะนำแอป
                  style: TextStyle(color: Colors.pinkAccent, fontSize: 14),
                ),
                const SizedBox(height: 8), // เว้นระยะห่างเล็กน้อย
                const Text(
                  "Cook like a chef", // ข้อความหลักของหน้า Welcome
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32), // เว้นระยะก่อนปุ่มกด
                SizedBox(
                  width: double.infinity, // ปุ่มกว้างเต็มแนวขวาง
                  height: 48, // ความสูงของปุ่ม
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent, // สีพื้นหลังปุ่ม
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24), // มุมปุ่มโค้งมน
                      ),
                    ),
                    onPressed: () {
                      // เมื่อกดปุ่มจะไปหน้า HomeScreen โดยแทนที่หน้าปัจจุบัน (ไม่สามารถกด back กลับมาได้)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    child: const Text(
                      "Get Started", // ข้อความในปุ่ม
                      style: TextStyle(fontSize: 20, color: Colors.white), // ตัวอักษรสีขาว
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


