import 'package:flutter/material.dart';
import 'package:ilaba/home_menu_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background colorful circle
            Positioned(
              top: 100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.pink.shade200, Colors.purple.shade400],
                  ),
                ),
              ),
            ),

            // Card with shadow
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: const Offset(8, 8),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    "Booking Confirmed!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Your laundry service has been successfully booked.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      backgroundColor: Color.fromARGB(255, 253, 132, 174),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeMenuScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Back to Home",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Decorative confetti effect (optional)
            Positioned(
              top: 60,
              right: 40,
              child: Icon(Icons.star, color: Colors.yellow.shade600, size: 40),
            ),
            Positioned(
              bottom: 80,
              left: 50,
              child: Icon(Icons.star, color: Colors.orange.shade400, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
