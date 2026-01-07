import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import 'my_addresses_screen.dart';
import 'faq_screen.dart';
import 'contact_us_screen.dart';
import 'my_orders_screen.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get current user info
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? "Guest User";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        automaticallyImplyLeading: false,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 2. User Info Header
            Center(
              child: Column(
                children: [

                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,

                    child: const Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  // Displaying actual email
                  Text(
                    userEmail,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 3. Menu Options Container
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2FBF4), // Light green background from design
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _ProfileMenuItem(
                                  icon: Icons.list_alt_outlined,
                                  title: "My orders",
                                  onTap: () {

                                    Navigator.push(context, MaterialPageRoute(builder: (_) => MyOrdersScreen()));
                                  },
                                ),
                  _ProfileMenuItem(
                                      icon: Icons.location_on_outlined,
                                      title: "My Addresses",
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAddressesScreen()));
                                      },
                                    ),
                  _ProfileMenuItem(
                                  icon: Icons.help_outline,
                                  title: "FAQ",
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen()));
                                  },
                                ),
                  _ProfileMenuItem(
                                  icon: Icons.support_agent_outlined,
                                  title: "Contact Us",
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen()));
                                  },
                                ),
                   // LOGOUT BUTTON
                  _ProfileMenuItem(
                    icon: Icons.logout,
                    title: "Log Out",
                    isLast: true, // To remove the divider
                    onTap: () async {
                      // 1. Sign out from Firebase
                      await FirebaseAuth.instance.signOut();

                      // 2. Navigate back to Login Screen and clear history stacks
                      if (context.mounted) {
                         // Use rootNavigator: true to ensure we exit the MainWrapper entirely
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
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

// --- HELPER WIDGETS ---

// A reusable widget for the menu items
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLast;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: const Color(0xFF4C9E57)), // Green icon color
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        ),
        // Add divider except for the last item
        if (!isLast)
          const Divider(height: 1, indent: 20, endIndent: 20, color: Colors.black12),
      ],
    );
  }
}

// just a placeholder for now
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Text("$title Coming Soon!", style: const TextStyle(fontSize: 18, color: Colors.grey)),
      ),
    );
  }
}