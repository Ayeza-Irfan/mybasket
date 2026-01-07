import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/bottom_nav_provider.dart';
import '../explore/explore_screen.dart';
import '../search/search_screen.dart';
import '../details/details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // BouncingScrollPhysics makes scrolling feel smoother
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 10),
                        Text(
                          "Search products and brands",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. Green Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF4C9E57),
                  borderRadius: BorderRadius.circular(15),
                  image: const DecorationImage(
                    image: AssetImage('assets/banner.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // 3. Top Categories Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Top Categories",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Switch to Explore Tab (Index 1)
                        context.read<BottomNavProvider>().updateIndex(1);
                      },
                      child: const Text(
                        "Explore all",
                        style: TextStyle(color: Color(0xFF4C9E57), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // 3b. Categories List (Firebase)
              SizedBox(
                height: 100,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) return const SizedBox();

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return CategoryItem(
                          title: data['name'] ?? '',
                          hexColor: data['color'] ?? '0xFFEEEEEE',
                          imageUrl: data['image'] ?? '',
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),

              // 4. Top Products
              const SectionHeader(title: "Top Products"),
              const SizedBox(height: 15),
              SizedBox(
                height: 220,
                child: _buildProductList(
                  FirebaseFirestore.instance.collection('products').snapshots(),
                ),
              ),

              const SizedBox(height: 25),

              // 5. Baby Products Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Get 25% Cashback",
                              style: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          const Text("on all baby products",
                              style: TextStyle(color: Colors.blueGrey)),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4C9E57)),
                            child: const Text("Shop Now",
                                style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/baby_products.png',
                      height: 100,
                      width: 100,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 6. Featured Items
              const SectionHeader(title: "Featured Items"),
              const SizedBox(height: 15),
              SizedBox(
                height: 220,
                child: _buildProductList(
                  FirebaseFirestore.instance
                      .collection('products')
                      .where('isFeatured', isEqualTo: true)
                      .snapshots(),
                  isFeaturedStyle: true,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER: Builds the product list ---
  Widget _buildProductList(Stream<QuerySnapshot> stream, {bool isFeaturedStyle = false}) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error loading");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data?.docs ?? [];
        if (data.isEmpty) return const Center(child: Text("No products"));

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: data.length,
          itemBuilder: (context, index) {
            var productData = data[index].data() as Map<String, dynamic>;

            // Wrap in GestureDetector to navigate to Details Screen
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(productData: productData),
                  ),
                );
              },
              child: ProductCard(
                title: productData['name'] ?? 'No Name',
                price: productData['price']?.toString() ?? '0',
                unit: productData['unit'] ?? '',
                discount: productData['discount'],
                imageUrl: productData['image'],
                isFeatured: isFeaturedStyle,
              ),
            );
          },
        );
      },
    );
  }
}

// --- UPDATED CATEGORY ITEM ---
class CategoryItem extends StatelessWidget {
  final String title;
  final String hexColor;
  final String imageUrl;

  const CategoryItem({
    super.key,
    required this.title,
    required this.hexColor,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    try {
      bgColor = Color(int.parse(hexColor));
    } catch (e) {
      bgColor = Colors.grey.shade200;
    }

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl, fit: BoxFit.contain)
                : const Icon(Icons.category, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// --- SECTION HEADER WIDGET ---
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () {

               // these "Explore all" buttons to also go to the Explore tab.
               context.read<BottomNavProvider>().updateIndex(1);
            },
            child: const Text("Explore all", style: TextStyle(color: Color(0xFF4C9E57), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// --- PRODUCT CARD WIDGET ---
class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String unit;
  final String? discount;
  final String? imageUrl;
  final bool isFeatured;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.unit,
    this.discount,
    this.imageUrl,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFeatured ? const Color(0xFFFFF1E4) : const Color(0xFFF2FBF4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (discount != null && discount!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4C9E57),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(discount!, style: const TextStyle(color: Colors.white, fontSize: 10)),
            )
          else
            const SizedBox(height: 20),

          Expanded(
            child: Center(
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(imageUrl!, fit: BoxFit.cover)
                  : Icon(Icons.fastfood, size: 60, color: Colors.grey[400]),
            ),
          ),

          const SizedBox(height: 10),
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("\$$price", style: const TextStyle(color: Color(0xFF4C9E57), fontWeight: FontWeight.bold)),
              Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}