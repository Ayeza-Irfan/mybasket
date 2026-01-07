import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import '../main_wrapper.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({super.key, required this.totalAmount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Tracks which address ID is currently selected
  String? _selectedAddressId;
  String _selectedPayment = 'cod';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text("Payment", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CONTACT DETAILS ---
              const Text("Contact Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildInput(_nameController, "Full Name", "Enter your name"),
              _buildInput(_emailController, "Email", "Enter email"),
              _buildInput(_phoneController, "Phone Number", "Enter phone number", isNumber: true),

              const SizedBox(height: 30),

              // --- DYNAMIC ADDRESS SECTION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Delivery Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () => _showAddressDialog(context, isNew: true),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add New"),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF4C9E57)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Fetch Addresses from Firebase
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('addresses')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text("No addresses found. Please add one.", textAlign: TextAlign.center),
                    );
                  }

                  // Auto-select the first address if none is selected
                  if (_selectedAddressId == null && docs.isNotEmpty) {
                    _selectedAddressId = docs.first.id;
                  }

                  return Column(
                    children: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final docId = doc.id;

                      return _AddressCard(
                        title: data['title'] ?? 'Address',
                        address: data['address'] ?? '',
                        value: docId,
                        groupValue: _selectedAddressId,
                        onChanged: (val) {
                          setState(() => _selectedAddressId = val);
                        },
                        onEdit: () => _showAddressDialog(context, isNew: false, id: docId, currentTitle: data['title'], currentAddress: data['address']),
                        onDelete: () => Provider.of<AddressProvider>(context, listen: false).deleteAddress(docId),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 30),

              // --- PAYMENT METHOD ---
              const Text("Choose payment method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _PaymentMethodTile(
                title: "Cash On Delivery",
                value: 'cod',
                groupValue: _selectedPayment,
                onChanged: (val) => setState(() => _selectedPayment = val!),
              ),
              _PaymentMethodTile(
                title: "Credit / Debit Card",
                value: 'card',
                groupValue: _selectedPayment,
                onChanged: (val) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Card payment not available right now.")));
                },
              ),

              const SizedBox(height: 40),

              // --- CONFIRM BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C9E57),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedAddressId == null) {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a delivery address")));
                         return;
                      }

                      // fetch the actual text of the selected address to save it in the order
                      final addressDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid)
                          .collection('addresses')
                          .doc(_selectedAddressId)
                          .get();

                      final addressData = addressDoc.data() as Map<String, dynamic>;

                      // 1. Prepare Data
                      Map<String, dynamic> shippingDetails = {
                        'name': _nameController.text,
                        'email': _emailController.text,
                        'phone': _phoneController.text,
                        'addressType': addressData['title'],
                        'fullAddress': addressData['address'],
                      };

                      // 2. Call Provider
                      await cartProvider.placeOrder(
                        totalAmount: widget.totalAmount,
                        shippingDetails: shippingDetails,
                        paymentMethod: _selectedPayment,
                      );

                      // 3. Success & Navigate
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Order Confirmed!"),
                          backgroundColor: Color(0xFF4C9E57),
                        ),
                      );

                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const MainWrapper()),
                          (route) => false,
                        );
                      });
                    }
                  },
                  child: const Text("Confirm Order", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REUSED DIALOG LOGIC (Same as MyAddressesScreen) ---
  void _showAddressDialog(BuildContext context, {required bool isNew, String? id, String? currentTitle, String? currentAddress}) {
    final titleController = TextEditingController(text: isNew ? '' : currentTitle);
    final addressController = TextEditingController(text: isNew ? '' : currentAddress);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isNew ? "Add Address" : "Edit Address"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Label (e.g. Home)")),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: "Full Address")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && addressController.text.isNotEmpty) {
                 final provider = Provider.of<AddressProvider>(context, listen: false);
                 if (isNew) {
                   provider.addAddress(titleController.text, addressController.text);
                 } else {
                   provider.updateAddress(id!, titleController.text, addressController.text);
                 }
                 Navigator.pop(context);
              }
            },
            child: const Text("Save", style: TextStyle(color: Color(0xFF4C9E57))),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildInput(TextEditingController controller, String label, String hint, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        validator: (val) => val!.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}

// --- ADDRESS CARD WIDGET ---
class _AddressCard extends StatelessWidget {
  final String title;
  final String address;
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.title,
    required this.address,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isSelected ? const Color(0xFF4C9E57) : Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: const Color(0xFF4C9E57),
        title: Row(
          children: [
            Icon(title.toLowerCase() == "home" ? Icons.home_outlined : Icons.work_outline, color: Colors.black54),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(address, style: const TextStyle(color: Colors.grey)),
        ),
        secondary: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _PaymentMethodTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final isDisabled = value == 'card';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? const Color(0xFF4C9E57) : Colors.grey.shade200),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: const Color(0xFF4C9E57),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, color: isDisabled ? Colors.grey : Colors.black),
        ),
        secondary: Icon(isDisabled ? Icons.credit_card_off : Icons.money, color: isDisabled ? Colors.grey : const Color(0xFF4C9E57)),
      ),
    );
  }
}