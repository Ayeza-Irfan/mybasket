import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/bottom_nav_provider.dart';

class DetailsScreen extends StatefulWidget {
  // We accept the product data dynamically
  final Map<String, dynamic> productData;

  const DetailsScreen({super.key, required this.productData});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int quantity = 1; // Start with 1 item

  @override
  Widget build(BuildContext context) {
    // Extract data for easier usage
    final String title = widget.productData['name'] ?? 'Product Name';
    final String price = widget.productData['price']?.toString() ?? '0';
    final String imageUrl = widget.productData['image'] ?? '';
    final String description = "Green apples have less sugar and carbs, and more fiber, protein, potassium, iron, and vitamin K, taking the lead as a healthier variety."; // Placeholder description

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Green Background Header
          Container(
            height: 350,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF4C9E57),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          // 2. Main Scrollable Content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      const Text(
                        "Details",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(), // Centers the title
                      const SizedBox(width: 40), // Balances the back button width
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Big Product Image
                        Center(
                          child: Container(
                            height: 250,
                            width: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                              ],
                            ),
                            child: ClipOval(
                              child: imageUrl.isNotEmpty
                                  ? Image.network(imageUrl, fit: BoxFit.cover)
                                  : Image.asset('assets/banner.png', fit: BoxFit.cover), // Fallback
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // White Content Area
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title and Quantity Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  // Quantity Counter
                                  Row(
                                    children: [
                                      _buildQtyButton(icon: Icons.remove, onTap: () {
                                        if (quantity > 1) setState(() => quantity--);
                                      }),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          "$quantity",
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      _buildQtyButton(icon: Icons.add, onTap: () {
                                        setState(() => quantity++);
                                      }),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 5),
                              const Text("Special price", style: TextStyle(color: Color(0xFF4C9E57), fontWeight: FontWeight.w600)),

                              const SizedBox(height: 10),

                              // Price Row
                              Row(
                                children: [
                                  Text(
                                    "\$$price",
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 15),
                                  const Text(
                                    "(42% off)",
                                    style: TextStyle(color: Color(0xFF4C9E57), fontWeight: FontWeight.bold, fontSize: 16)
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),
                              const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Text(
                                description,
                                style: TextStyle(color: Colors.grey[600], height: 1.5),
                              ),

                              const SizedBox(height: 30),

                              // Related Items Header
                              const Text("Related items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 15),


                              // Horizontal List for Related Items
                                                            SizedBox(
                                                              height: 150,
                                                              child: ListView(
                                                                scrollDirection: Axis.horizontal,

                                                                padding: const EdgeInsets.only(left: 5, right: 20, bottom: 10),
                                                                children: const [
                                                                  _RelatedItemCard(
                                                                    title: "Pineapple",
                                                                    color: Colors.orange,
                                                                    imagePath: 'assets/pineapple.png',
                                                                  ),
                                                                  _RelatedItemCard(
                                                                    title: "Strawberry",
                                                                    color: Colors.redAccent,
                                                                    imagePath: 'assets/strawberry.png',
                                                                  ),
                                                                  _RelatedItemCard(
                                                                    title: "Grapes",
                                                                    color: Colors.lightGreen,
                                                                    imagePath: 'assets/grapes.png',
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                              const SizedBox(height: 100), // Space for bottom button
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Add to Cart Button (Bottom)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C9E57),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                onPressed: () async {
                                  // 1. Add to Firebase
                                  await Provider.of<CartProvider>(context, listen: false).addToCart(
                                    productId: widget.productData['name'], // Using name as ID for simplicity
                                    title: widget.productData['name'],
                                    image: widget.productData['image'],
                                    price: widget.productData['price'].toString(),
                                    unit: widget.productData['unit'] ?? 'kg',
                                    quantity: quantity,
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Added $quantity $title to Cart")),
                                  );

                                  // 2. Switch to Cart Tab (Index 2 in MainWrapper)
                                  // Use a small delay so the user sees the snackbar first
                                  Future.delayed(const Duration(milliseconds: 500), () {
                                     // We need to pop 'Details' first to get back to the wrapper
                                     Navigator.pop(context);
                                     // Then switch the tab
                                     Provider.of<BottomNavProvider>(context, listen: false).updateIndex(2);
                                  });
                                },
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for +/- buttons
  Widget _buildQtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.grey),
      ),
    );
  }
}

// Helper for "Related Items" (Static visual only as per design)
// --- HELPER WIDGET FOR RELATED ITEMS ---
class _RelatedItemCard extends StatelessWidget {
  final String title;
  final Color color;
  final String imagePath;

  const _RelatedItemCard({
    required this.title,
    required this.color,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2), // The tinted background
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain, // Ensures the image fits well
              ),
            ),
          ),
          // -------------------------------

          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),

          // The little "+" button at the bottom
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Colors.white, size: 14),
          )
        ],
      ),
    );
  }
}