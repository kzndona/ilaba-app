import 'package:flutter/material.dart';

class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // TODO: Open Side Menu
            }
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                // TODO: Open Notifications
              },
          ),
        ],
      ),
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
                      fit: BoxFit.cover
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
                // Main Buttons
              ),
              Container(
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: const Text('Book Service'),
                        onPressed: () {
                            // TODO: Navigate to Create Order Customer Screen
                          },
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: OutlinedButton(
                                child: const Text('View Order History'),
                                onPressed: () {
                                  // TODO: Navigate to Order History Screen
                                },
                            )
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Expanded(
                            child: OutlinedButton(
                                child: const Text('Loyalty Card'),
                                onPressed: () {
                                  // TODO: Navigate to Loyalty Card Screen
                                }
                            )
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
      ),
    );
  }
}