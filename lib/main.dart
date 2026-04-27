import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/bottom_nav_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/address_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAmaXDOQJUYtf6PcuhRLp-m54N9geAEiEE",

      authDomain: "mybasket-9b175.firebaseapp.com",

      projectId: "mybasket-9b175",

      storageBucket: "mybasket-9b175.firebasestorage.app",

      messagingSenderId: "83855560536",

      appId: "1:83855560536:web:bcb09146230a6f27e81f2d"
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
      ],
      child: MaterialApp(
        title: 'MyBasket',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        
        // --- THIS IS THE RESPONSIVE WRAPPER ---
        builder: (context, child) {
          return Container(
            color: Colors.grey[200], // The background color for empty desktop space
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600, // Locks the app width to mobile size
                ),
                // ClipRect cuts off any animations or shadows that try to bleed outside the 600px box
                child: ClipRect(
                  child: child!,
                ),
              ),
            ),
          );
        },
        // ---------------------------------------

        home: const LoginScreen(),
      ),
    );
  }
}