import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Selected Address State (to share selection between screens)
  String _selectedAddressId = "";
  String get selectedAddressId => _selectedAddressId;

  void selectAddress(String id) {
    _selectedAddressId = id;
    notifyListeners();
  }

  // --- ACTIONS ---

  // 1. ADD ADDRESS
  Future<void> addAddress(String title, String fullAddress) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).collection('addresses').add({
      'title': title,
      'address': fullAddress,
      'createdAt': FieldValue.serverTimestamp(),
    });
    notifyListeners();
  }

  // 2. UPDATE ADDRESS
  Future<void> updateAddress(String id, String title, String fullAddress) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).collection('addresses').doc(id).update({
      'title': title,
      'address': fullAddress,
    });
    notifyListeners();
  }

  // 3. DELETE ADDRESS
  Future<void> deleteAddress(String id) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).collection('addresses').doc(id).delete();
    notifyListeners();
  }
}