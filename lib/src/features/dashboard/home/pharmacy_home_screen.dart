import 'package:flutter/material.dart';
import 'package:med_shakthi/src/features/cart/cart_page.dart';
import 'package:med_shakthi/src/product/product_page.dart';

/// This screen implements the "med Shakti home page "
class PharmacyHomeScreen extends StatefulWidget {
  const PharmacyHomeScreen({super.key});

  @override
  State<PharmacyHomeScreen> createState() => _PharmacyHomeScreenState();
}

class _PharmacyHomeScreenState extends State<PharmacyHomeScreen> {
  // State allows us to track dynamic changes, like the selected tab in the navigation bar.
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildTopBar(), // Top Bar
              const SizedBox(height: 24),
              _buildPromoBanner(), // Promo Banner
              const SizedBox(height: 24),
              _buildSectionTitle(
                "Categories",
                "See All",
                () {},
              ), // categories Title
              const SizedBox(height: 16),
              _buildCategoriesList(), // Categories List
              const SizedBox(height: 24),
              _buildSectionTitle(
                "Bestseller Products",
                "See All",
                () {},
              ), // Bestseller Products Title
              const SizedBox(height: 16),
              _buildBestsellersList(), // Bestsellers List
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(), // Bottom Navigation Bar
    );
  }

  // --- Widget code block ---

  /// Builds the top bar containing the Scan button, Search bar, and Cart button.
  Widget _buildTopBar() {
    return Row(
      children: [
        _buildIconBox(Icons.crop_free, () {}), // Scan Button
        const SizedBox(width: 12),
        // Search  Bar
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                30,
              ), // Fully rounded pills are trendy
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.1),
              ), // Subtle border
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Search medicine",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                Icon(Icons.camera_alt_outlined, color: Colors.black),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Cart Button with Badge
        Stack(
          clipBehavior:
              Clip.none, // Allows elements to go outside the stack bounds
          children: [
            _buildIconBox(Icons.shopping_cart_outlined, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            }),
            // Notification Badge
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E88E5), // Blue accent color
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '0', // Example count
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Helper to build a square icon button with shadow
  Widget _buildIconBox(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14), // Squircle shape
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4), // Shadow position
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 24),
      ),
    );
  }

  /// Builds the promo banner with gradient background and image.
  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      height: 170, // Fixed height for consistency
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        // A complex gradient gives a polished, high-end feel compared to a flat color.
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5A9CA0), // Teal-ish color from image
            Color(0xFF3A6B6E), // Darker teal
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A9CA0).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Decor (Circles) creating that subtle overlay effect
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),

          // Text Content
          Positioned(
            left: 24,
            top: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pharmacy Made Easy",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Delivery of your discussion", // Copy from image
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                const Text(
                  "15% OFF",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                // 'Shop Now' Button
                IntrinsicWidth(
                  // Wraps content tightly
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        "Shop Now",
                        style: TextStyle(
                          color: Color(0xFF3A6B6E), // Text matches banner bg
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Doctor Image
          // Ideally you'd use an asset image. Here we use a transparent PNG from network.
          Positioned(
            right: 10,
            bottom: 0,
            child: Image.network(
              // Placeholder doctor image
              'http://pngimg.com/uploads/doctor/doctor_PNG16001.png',
              height: 160,
              fit: BoxFit.fitHeight,
              // Fallback if image fails to load
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person,
                  size: 100,
                  color: Colors.white24,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable section title with "See All" button
  Widget _buildSectionTitle(
    String title,
    String actionText,
    VoidCallback onAction,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title, // e.g., "Categories"
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionText, // e.g., "See All"
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5A9CA0), // Brand color
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the horizontal list of circular categories
  Widget _buildCategoriesList() {
    // Data list representing the categories
    final categories = [
      {
        'name': 'Medicines',
        'icon': Icons.medication,
        'color': Colors.blue[100],
      },
      {
        'name': 'Health',
        'icon': Icons.favorite,
        'color': Colors.red[100],
      }, // Shortened 'Health Devices'
      {
        'name': 'Vitamins',
        'icon': Icons.wb_sunny,
        'color': Colors.orange[100],
      }, // 'Supplements'
      {
        'name': 'Care',
        'icon': Icons.spa,
        'color': Colors.green[100],
      }, // 'Personal Care'
      {
        'name': 'Medicines',
        'icon': Icons.medication,
        'color': Colors.blue[100],
      },
      {
        'name': 'Health',
        'icon': Icons.favorite,
        'color': Colors.red[100],
      }, // Shortened 'Health Devices'
      {
        'name': 'Vitamins',
        'icon': Icons.wb_sunny,
        'color': Colors.orange[100],
      }, // 'Supplements'
      {'name': 'Care', 'icon': Icons.spa, 'color': Colors.green[100]},
    ];

    return SizedBox(
      height: 100, // Constrained height for row
      child: ListView.separated(
        scrollDirection: Axis.horizontal, // Horizontal scrolling
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 20), // Spacing between items
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Column(
            children: [
              // Circle Background
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white, // White bg for the circle
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  // We display dynamic icons here. In a real app these might be images.
                  child: Icon(
                    cat['icon'] as IconData,
                    color:
                        (cat['color'] as Color?)?.withValues(alpha: 1.0) ??
                        Colors.blue, // Using the color for the icon
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cat['name'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds the horizontal list of product cards
  Widget _buildBestsellersList() {
    return SizedBox(
      height: 260, // Height enough to fit image + text + price
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none, // Allow shadow to flow outside
        itemCount: 7,
        itemBuilder: (context, index) {
          // Alternatig dummy data
          final bool isMilkThistle = index % 2 == 0;
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductPage()),
            ),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Area
                  Expanded(
                    child: Center(
                      child: Image.network(
                        isMilkThistle
                            ? 'https://pngimg.com/uploads/pills/pills_PNG98765.png' // Dummy pill bottle
                            : 'https://pngimg.com/uploads/vitamin_bottle/vitamin_bottle_PNG9.png',
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    isMilkThistle
                        ? "Milk Thistle Liver Care"
                        : "Puregen Cold Relief",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Subtitle / Category
                  Text(
                    isMilkThistle ? "Supplements" : "Medicine",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  // Rating Row
                  const Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "4.8 (2.2k)",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Price and Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "\$16.99",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      // Add Button (+)
                      Container(
                        height: 32,
                        width: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFF5A9CA0), // Brand color
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Custom Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home, "Home", 0),
              _buildNavItem(Icons.grid_view, "Category", 1),
              _buildNavItem(Icons.favorite_border, "Wishlist", 2),
              _buildNavItem(Icons.receipt_long, "Order", 3),
              _buildNavItem(Icons.person_outline, "Profile", 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF5A9CA0) : Colors.grey,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF5A9CA0) : Colors.grey,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
