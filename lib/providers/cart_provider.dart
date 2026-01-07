import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Coupon State
  double _couponDiscount = 0.0;
  String _appliedCouponCode = "";

  double get couponDiscount => _couponDiscount;
  String get appliedCouponCode => _appliedCouponCode;

  // --- ACTIONS ---

  // Add item to Firestore Cart
  Future<void> addToCart({
    required String productId,
    required String title,
    required String image,
    required String price,
    required String unit,
    int quantity = 1,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    final cartRef = _firestore.collection('users').doc(user.uid).collection('cart').doc(productId);

    // Check if item already exists to update quantity
    final doc = await cartRef.get();
    if (doc.exists) {
      await cartRef.update({
        'quantity': FieldValue.increment(quantity),
      });
    } else {
      await cartRef.set({
        'productId': productId,
        'name': title,
        //'image': image,
        'price': double.tryParse(price) ?? 0.0,
        'unit': unit,
        'quantity': quantity,
        'addedAt': DateTime.now(),
      });
    }
    notifyListeners();
  }

  // Remove or Decrease Quantity
  Future<void> decrementItem(String productId) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    final cartRef = _firestore.collection('users').doc(user.uid).collection('cart').doc(productId);
    final doc = await cartRef.get();

    if (doc.exists) {
      int currentQty = doc['quantity'];
      if (currentQty > 1) {
        await cartRef.update({'quantity': FieldValue.increment(-1)});
      } else {
        await cartRef.delete();
      }
    }
    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    User? user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).collection('cart').doc(productId).delete();
    notifyListeners();
  }

  // Increment Quantity
  Future<void> incrementItem(String productId) async {
    User? user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).collection('cart').doc(productId).update({
      'quantity': FieldValue.increment(1),
    });
    notifyListeners();
  }

  // --- COUPON LOGIC ---
  void applyCoupon(String code, double discountValue) {
    if (_appliedCouponCode == code) {
      _appliedCouponCode = "";
      _couponDiscount = 0.0;
    } else {
      _appliedCouponCode = code;
      _couponDiscount = discountValue;
    }
    notifyListeners();
  }



  // 1. CHECK IF FIRST ORDER
  Future<bool> checkIsFirstOrder() async {
    User? user = _auth.currentUser;
    if (user == null) return false;

    // Check if the 'orders' collection has any documents for this user
    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.isEmpty; // Returns true if NO orders exist
  }

  // 2. PLACE ORDER (Updated to save Contact & Address)
    Future<void> placeOrder({
      required double totalAmount,
      required Map<String, dynamic> shippingDetails,
      required String paymentMethod,
    }) async {
      User? user = _auth.currentUser;
      if (user == null) return;

      // A. Get current cart items
      final cartSnapshot = await _firestore.collection('users').doc(user.uid).collection('cart').get();

      // B. Create a new Order Object with REAL DETAILS
      await _firestore.collection('orders').add({
        'userId': user.uid,
        'totalAmount': totalAmount,
        'date': DateTime.now(),
        'items': cartSnapshot.docs.map((doc) => doc.data()).toList(),
        'status': 'Pending',
        'paymentMethod': paymentMethod,
        'shippingDetails': shippingDetails, // <--- Saving the User's Input
      });

      // C. Clear the Cart after ordering
      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      // D. Reset Coupon
      _couponDiscount = 0.0;
      _appliedCouponCode = "";
      notifyListeners();
    }

}