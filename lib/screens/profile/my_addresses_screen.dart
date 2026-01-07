import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/address_provider.dart';

class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4C9E57), // Green Header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Addresses",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 1. Add New Address Button (Top)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              onTap: () => _showAddressDialog(context, isNew: true),
              child: Row(
                children: const [
                  Icon(Icons.add_circle_outline, color: Color(0xFF4C9E57), size: 28),
                  SizedBox(width: 10),
                  Text(
                    "Add New Address",
                    style: TextStyle(
                      color: Color(0xFF4C9E57),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Address List from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                  return const Center(child: Text("No addresses saved."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    final isSelected = addressProvider.selectedAddressId == docId;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF4C9E57) : Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: Radio<String>(
                          value: docId,
                          groupValue: addressProvider.selectedAddressId,
                          activeColor: const Color(0xFF4C9E57),
                          onChanged: (val) {
                            if (val != null) addressProvider.selectAddress(val);
                          },
                        ),
                        title: Row(
                          children: [
                            Icon(
                              _getIconForTitle(data['title']),
                              size: 20,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              data['title'] ?? 'Address',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(data['address'] ?? ''),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey),
                              onPressed: () => _showAddressDialog(
                                context,
                                isNew: false,
                                id: docId,
                                currentTitle: data['title'],
                                currentAddress: data['address'],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                              onPressed: () => addressProvider.deleteAddress(docId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper to show Icon based on Title ---
  IconData _getIconForTitle(String? title) {
    if (title == null) return Icons.location_on_outlined;
    final t = title.toLowerCase();
    if (t.contains('home')) return Icons.home_outlined;
    if (t.contains('office') || t.contains('work')) return Icons.work_outlined;
    return Icons.location_on_outlined;
  }

  // --- Add/Edit Dialog ---
  void _showAddressDialog(BuildContext context,
      {required bool isNew, String? id, String? currentTitle, String? currentAddress}) {
    final titleController = TextEditingController(text: isNew ? '' : currentTitle);
    final addressController = TextEditingController(text: isNew ? '' : currentAddress);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isNew ? "Add New Address" : "Edit Address"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Label (e.g. Home, Office)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Full Address"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4C9E57)),
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
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}