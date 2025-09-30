import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {
        "orderNo": "ORD-001",
        "date": "Sept 30, 2025",
        "status": "Completed",
        "items": "2 Wash, 1 Dry",
        "total": "₱350",
        "address": "Bagumbong Area",
      },
      {
        "orderNo": "ORD-002",
        "date": "Sept 29, 2025",
        "status": "Pending",
        "items": "3 Wash",
        "total": "₱300",
        "address": "Bagumbong Area",
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Order History")),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ExpansionTile(
              title: Text(order["orderNo"]!),
              subtitle: Text("${order["date"]} • ${order["status"]}"),
              children: [
                ListTile(
                  title: const Text("Items"),
                  subtitle: Text(order["items"]!),
                ),
                ListTile(
                  title: const Text("Total"),
                  subtitle: Text(order["total"]!),
                ),
                ListTile(
                  title: const Text("Address"),
                  subtitle: Text(order["address"]!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
