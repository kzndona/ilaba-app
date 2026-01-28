import 'package:flutter/material.dart';
import 'package:ilaba/screens/info/help_center_screen.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        "question": "What are your operating hours?",
        "answer": "We are open daily from 7:00 AM to 8:00 PM.",
      },
      {
        "question": "What areas do you deliver?",
        "answer": "Currently, we deliver only within Bagumbong area.",
      },
      {
        "question": "When can I book your service?",
        "answer": "Bookings are accepted daily from 10:00 AM to 3:00 PM.",
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("FAQs")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                final item = faqs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      item["question"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          item["answer"]!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Help Center button at bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 253, 132, 174),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpCenterScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.support_agent),
              label: const Text(
                "Help Center",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
