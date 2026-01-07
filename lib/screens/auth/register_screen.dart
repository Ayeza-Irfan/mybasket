import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../main_wrapper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Back button color
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                Center(
                  child: Image.asset(
                    'assets/logo_full.png',
                    height: 70,
                    fit: BoxFit.contain,
                  ),
                ),
                // ---------------------------

                const SizedBox(height: 30),
                const Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4C9E57)
                  )
                ),
                const SizedBox(height: 20),

                // Fields
                _buildLabel("Your Name"),
                _buildInput(_nameController, "Enter Your Name"),

                _buildLabel("Email Id"),
                _buildInput(_emailController, "Enter Your Email Id"),

                _buildLabel("Password"),
                _buildInput(_passwordController, "Enter Your Password", isPassword: true),

                _buildLabel("Confirm Password"),
                _buildInput(_confirmPasswordController, "Confirm Your Password", isPassword: true),

                _buildLabel("Contact Number"),
                _buildInput(_phoneController, "Enter Your Contact Number", isNumber: true),

                const SizedBox(height: 30),

                // Register Button
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
                        // Check if passwords match
                        if (_passwordController.text != _confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Passwords do not match"))
                          );
                          return;
                        }

                        // Call Provider
                        String? error = await authProvider.registerUser(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                          name: _nameController.text.trim(),
                          phone: _phoneController.text.trim(),
                        );

                        if (error != null) {
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                                                } else {
                                                  // Success! Navigate to MainWrapper (Home)
                                                  // pushAndRemoveUntil removes all previous routes (Login/Register)
                                                  // so the user can't hit "Back" to return to the registration screen.
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(builder: (_) => const MainWrapper()),
                                                    (route) => false,
                                                  );

                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text("Registration Successful! Welcome."))
                                                  );
                                                }
                      }
                    },
                    child: authProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Register", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 20),

                // Back to Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already Have an Account? "),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 10.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, {bool isPassword = false, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
      validator: (value) => value!.isEmpty ? "Required" : null,
    );
  }
}