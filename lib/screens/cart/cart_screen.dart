import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/cart_provider.dart';
import '../payment/payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final cartProvider = Provider.of<CartProvider>(context);

    if (user == null) return const Scaffold(body: Center(child: Text("Please login")));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Cart",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),

      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .orderBy('addedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartItems = snapshot.data?.docs ?? [];

          if (cartItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Your cart is empty", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // --- CALCULATE TOTALS ---
          double totalMrp = 0.0;
          for (var doc in cartItems) {
            final data = doc.data() as Map<String, dynamic>;
            totalMrp += (data['price'] ?? 0) * (data['quantity'] ?? 1);
          }

          double finalAmount = totalMrp - cartProvider.couponDiscount;
          if (finalAmount < 0) finalAmount = 0;

          return Column(
            children: [
              // 1. Delivery Time Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Tomorrow, 7 AM - 9 PM", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    SizedBox(width: 5),
                    Icon(Icons.keyboard_arrow_down, color: Color(0xFF4C9E57)),
                  ],
                ),
              ),

              // 2. Cart Items List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final data = cartItems[index].data() as Map<String, dynamic>;
                    final docId = cartItems[index].id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        children: [
                          // Image
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(data['image'] ?? ''),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    // Remove Button (X)
                                    GestureDetector(
                                      onTap: () => cartProvider.removeItem(docId),
                                      child: const Icon(Icons.close, size: 20, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(data['unit'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 10),

                                // Price & Quantity Controls
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("\$${data['price']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

                                    // + / - Buttons
                                    Row(
                                      children: [
                                        _QtyBtn(icon: Icons.remove, onTap: () => cartProvider.decrementItem(docId)),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Text("${data['quantity']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        _QtyBtn(icon: Icons.add, onTap: () => cartProvider.incrementItem(docId)),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // 3. Coupons Section (Scrollable)
              SizedBox(
                height: 70,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _CouponCard(
                                          color: const Color(0xFF53B175),
                                          title: "FLAT 50% off",
                                          subTitle: "on your first order",
                                          code: "GETFIRST",
                                          discountValue: totalMrp * 0.50,
                                          isSelected: cartProvider.appliedCouponCode == "GETFIRST",
                                          onTap: () async {
                                            // 1. Check if user is eligible
                                            bool isFirst = await cartProvider.checkIsFirstOrder();

                                            if (isFirst) {
                                              cartProvider.applyCoupon("GETFIRST", totalMrp * 0.50);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("First Order Coupon Applied!")),
                                              );
                                            } else {
                                              // 2. Show error if not first order
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("This coupon is only for your first order.")),
                                              );
                                            }
                                          },
                                        ),
                    _CouponCard(
                      color: const Color(0xFFD3B0E0), // Purple/Pinkish
                      title: "Get \$5 off",
                      subTitle: "on orders above \$20",
                      code: "DOLLAR5",
                      discountValue: 5.0,
                      isSelected: cartProvider.appliedCouponCode == "DOLLAR5",
                      onTap: () {
                        if (totalMrp > 20) {
                          cartProvider.applyCoupon("DOLLAR5", 5.0);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order must be above \$20")));
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. Payment Details Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
                ),
                child: Column(
                  children: [
                    _SummaryRow(title: "Total MRP", value: "\$${totalMrp.toStringAsFixed(2)}"),
                    _SummaryRow(title: "Discount", value: "-\$${cartProvider.couponDiscount.toStringAsFixed(2)}"),
                    const _SummaryRow(title: "Shipping Charges", value: "Free"),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text("\$${finalAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 20),


                                        // Checkout Button
                                                            SizedBox(
                                                              width: double.infinity,
                                                              height: 55,
                                                              child: ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor: const Color(0xFF4C9E57),
                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                                                ),
                                                                onPressed: () {
                                                                  // Navigate to Payment Screen and pass the final amount
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) => PaymentScreen(totalAmount: finalAmount),
                                                                    ),
                                                                  );
                                                                },
                                                                child: const Text("Checkout", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                                              ),
                                                            )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF4C9E57)),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  const _SummaryRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final Color color;
  final String title;
  final String subTitle;
  final String code;
  final double discountValue;
  final bool isSelected;
  final VoidCallback onTap;

  const _CouponCard({
    required this.color,
    required this.title,
    required this.subTitle,
    required this.code,
    required this.discountValue,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(isSelected ? 1.0 : 0.8), // Darken if selected
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subTitle, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(5)),
              child: Text(code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
            )
          ],
        ),
      ),
    );
  }
}