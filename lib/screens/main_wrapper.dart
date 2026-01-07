import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bottom_nav_provider.dart';
import 'home/home_screen.dart';
import 'explore/explore_screen.dart';
import 'cart/cart_screen.dart';
import 'profile/profile_screen.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    CartScreen(),

    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavProvider>(
      builder: (context, navProvider, child) {
        return Scaffold(
          body: _screens[navProvider.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navProvider.currentIndex,
            onTap: (index) {
              navProvider.updateIndex(index);
            },
            type: BottomNavigationBarType.fixed,


            backgroundColor: const Color(0xFF4C9E57), // Green Background
            selectedItemColor: Colors.white,          // White for active tab
            unselectedItemColor: Colors.white70,      // Slightly faded white for inactive tabs


            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explore'),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),

              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}