import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';
import '../main_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // --- LOGO AREA  ---

                Center(
                  child: Image.asset(
                    'assets/logo_full.png',
                    height: 70,
                    fit: BoxFit.contain,
                  ),
                ),


                const SizedBox(height: 40),

                // Illustration
                Center(
                  child: Image.asset('assets/login_illustration.png', height: 180),
                ),

                const SizedBox(height: 40),

                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4C9E57)
                  )
                ),
                const SizedBox(height: 20),

                // Email Input
                const Text("Email Id", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Enter Your Email Id",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) => value!.isEmpty ? "Please enter email" : null,
                ),
                const SizedBox(height: 20),

                // Password Input
                const Text("Password", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Enter Your Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) => value!.length < 6 ? "Password too short" : null,
                ),
                const SizedBox(height: 30),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C9E57),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: authProvider.isLoading ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        String? error = await authProvider.loginUser(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        );

                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                        } else {

                          // TODO: Navigate to Home Screen
                          print("Login Successful");
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(builder: (_) => const MainWrapper())
                                                    );
                        }
                      }
                    },
                    child: authProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 20),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't You Have an Account? "),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen())
                      ),
                      child: const Text("Register", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ], // Closes Column children
            ), // Closes Column
          ), // Closes Form
        ), // Closes SingleChildScrollView
      ), // Closes SafeArea
    ); // Closes Scaffold
  }
}