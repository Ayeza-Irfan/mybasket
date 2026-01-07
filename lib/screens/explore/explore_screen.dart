import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <--- Import Provider
import '../../providers/bottom_nav_provider.dart';
import '../details/details_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),

                onPressed: () => context.read<BottomNavProvider>().updateIndex(0),
              ),
              title: const Text(
                "Explore",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            // We add a section for each category
            _CategorySection(categoryName: "Groceries"),
            _CategorySection(categoryName: "Vegetables"),
            _CategorySection(categoryName: "Fruits"),
            _CategorySection(categoryName: "Dairy Products"),
            _CategorySection(categoryName: "Bakery Items"),
          ],
        ),
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _CategorySection extends StatelessWidget {
  final String categoryName;
  const _CategorySection({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                "See all",
                style: TextStyle(color: Color(0xFF4C9E57), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Horizontal Product List for this Category
        SizedBox(
          height: 240, // Height for the product card container
          child: StreamBuilder<QuerySnapshot>(
            // Fetch products that match this category name
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('category', isEqualTo: categoryName)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Text("Something went wrong");
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data!.docs;
              if (data.isEmpty) {

                return Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: Text("No items in $categoryName yet."),
                );
              }

              return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                // Get the data map
                                var productData = data[index].data() as Map<String, dynamic>;

                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to Details Page passing the data
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailsScreen(productData: productData),
                                      ),
                                    );
                                  },
                                  child: ExploreProductCard(
                                    title: productData['name'] ?? 'No Name',
                                    price: productData['price']?.toString() ?? '0',
                                    unit: productData['unit'] ?? '',
                                    imageUrl: productData['image'] ?? '',
                                  ),
                                );
                              },
                            );
            },
          ),
        ),
      ],
    );
  }
}

// A specialized product card to match the Explore screen design
class ExploreProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String unit;
  final String imageUrl;

  const ExploreProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.unit,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2FBF4), // Light green background
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            child: Center(
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.contain)
                  : Icon(Icons.image_not_supported, size: 80, color: Colors.grey[300]),
            ),
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          // Unit (e.g., 1 kg)
          Text(
            unit,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 10),

          // Price and Add Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$$price",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              // Add Button
              Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFF4C9E57), // Green color
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}