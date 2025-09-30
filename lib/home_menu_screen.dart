import 'package:flutter/material.dart';
import 'package:ilaba/booking_map.dart';
import 'package:ilaba/faq_screen.dart';
import 'package:ilaba/loyalty_screen.dart';
import 'package:ilaba/menu_side_screen.dart';
import 'package:ilaba/order_history_screen.dart';
import 'package:ilaba/order_status.dart';

class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text('iLABa Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Open Notifications
            },
          ),
        ],
      ),

      drawer: const MenuSideScreen(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/images/banner.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Menu Cards
            Expanded(
              child: ListView(
                children: [
                  MenuCard(
                    title: "Book a Service",
                    description: "Schedule your laundry pick-up and delivery.",
                    icon: Icons.shopping_bag,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BookingMapScreen(),
                        ),
                      );
                    },
                  ),
                  MenuCard(
                    title: "Check Order Status",
                    description: "Track your current laundry orders.",
                    icon: Icons.track_changes,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderStatusScreen(),
                        ),
                      );
                    },
                  ),
                  MenuCard(
                    title: "View Order History",
                    description: "See your past orders and receipts.",
                    icon: Icons.history,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  MenuCard(
                    title: "Loyalty Card Program",
                    description: "Check your points and rewards.",
                    icon: Icons.card_membership,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoyaltyProgramScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // FAQ & Help Center button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 253, 132, 174),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FAQScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.help_outline),
                      label: const Text(
                        "FAQ & Help Center",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Menu Card Widget
class MenuCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onPressed;

  const MenuCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Left: Title, description, button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 64,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Color.fromARGB(255, 253, 132, 174),
                    elevation: 0,
                  ),
                  onPressed: onPressed,
                  child: const Text(
                    'Go',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Right: Icon
          Container(
            margin: const EdgeInsets.only(left: 16),
            child: Icon(
              icon,
              size: 48,
              color: Color.fromARGB(255, 253, 132, 174),
            ),
          ),
        ],
      ),
    );
  }
}
