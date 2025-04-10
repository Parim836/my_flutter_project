import 'package:flutter/material.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // สีพื้นหลังชมพูอ่อน
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 300,
                  child: Image.network(
                    'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExMGFhNzVvM21hZXI3ODZiZGNlYWk5NXB5M2tvbjIxcjI4Y2pybTNzNSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9cw/YoKaNSoTHog8Y3550r/giphy.gif',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Premium food recipes",
                  style: TextStyle(color: Colors.pinkAccent, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Cook like a chef",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    child: const Text(
                      "Get Started",
                      style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 255, 255, 255)),
                      
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
