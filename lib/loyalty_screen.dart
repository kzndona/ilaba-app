import 'package:flutter/material.dart';

class LoyaltyProgramScreen extends StatelessWidget {
  const LoyaltyProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int transactions = 12; // Example: user has 12 transactions

    return Scaffold(
      appBar: AppBar(
        title: const Text("Loyalty Program"),
        backgroundColor: Color.fromARGB(255, 253, 132, 174),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Earn Discounts as You Book!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Progress bar
            LinearProgressIndicator(
              value: transactions / 20,
              minHeight: 12,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: Colors.grey.shade300,
              color: Color.fromARGB(255, 253, 132, 174),
            ),
            const SizedBox(height: 12),
            Text(
              "$transactions / 20 transactions",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 30),

            // Rewards
            Expanded(
              child: ListView(
                children: [
                  _rewardCard(
                    label: "10 Transactions",
                    discount: "10% Discount",
                    achieved: transactions >= 10,
                  ),
                  const SizedBox(height: 16),
                  _rewardCard(
                    label: "20 Transactions",
                    discount: "15% Discount",
                    achieved: transactions >= 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rewardCard({
    required String label,
    required String discount,
    required bool achieved,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: achieved
            ? LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade700],
              )
            : LinearGradient(
                colors: [Colors.grey.shade300, Colors.grey.shade400],
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: achieved ? Colors.green.shade200 : Colors.grey.shade500,
            offset: const Offset(4, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: achieved ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                discount,
                style: TextStyle(
                  fontSize: 16,
                  color: achieved ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
          Icon(
            achieved ? Icons.check_circle : Icons.lock,
            size: 40,
            color: achieved ? Colors.white : Colors.black45,
          ),
        ],
      ),
    );
  }
}
