import 'package:flutter/material.dart';
import 'package:ilaba/screens/login_screen.dart';

class MenuSideScreen extends StatelessWidget {
  const MenuSideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 253, 132, 174),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Color.fromARGB(255, 253, 132, 174),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Welcome, User!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Navigation items
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Accounts"),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Accounts screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to FAQs screen
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log out"),
            textColor: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
