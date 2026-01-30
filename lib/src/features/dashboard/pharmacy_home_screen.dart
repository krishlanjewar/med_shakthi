import 'package:flutter/material.dart';
import 'package:med_shakthi/src/features/category/category_ui.dart';
import 'package:med_shakthi/src/features/products/data/repositories/product_repository.dart';
import 'package:med_shakthi/src/features/wishlist/data/wishlist_service.dart';
import 'package:med_shakthi/src/features/wishlist/presentation/screens/wishlist_page.dart';
import 'package:med_shakthi/src/features/cart/presentation/screens/cart_page.dart';
import 'package:med_shakthi/src/features/orders/orders_page.dart';
import 'package:med_shakthi/src/features/products/presentation/screens/product_page.dart';
import 'package:provider/provider.dart';
import '../orders/chat_screen.dart';
import '../profile/presentation/screens/ai_assistant_page.dart';
import '../profile/presentation/screens/chat_details_screen.dart';
import '../profile/presentation/screens/profile_screen.dart';
import 'package:med_shakthi/src/features/cart/data/cart_data.dart';
import 'package:med_shakthi/src/features/cart/data/cart_item.dart';
import 'package:med_shakthi/src/features/products/data/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// This screen implements the "Med Shakti home page" for Retailers
class PharmacyHomeScreen extends StatefulWidget {
  const PharmacyHomeScreen({super.key});

  @override
  State<PharmacyHomeScreen> createState() => _PharmacyHomeScreenState();
}

class WishlistServiceSingleton {
  static final WishlistService instance = WishlistService(userId: 'demo-user');
}

class _PharmacyHomeScreenState extends State<PharmacyHomeScreen> {
  // State allows us to track dynamic changes, like the selected tab in the navigation bar.
  int _selectedIndex = 0;
  final ProductRepository _productRepo = ProductRepository();

  final WishlistService wishlistService = WishlistServiceSingleton.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(),
          const CategoryPageNew(),
          WishlistPage(wishlistService: wishlistService),
          const OrdersPage(),
          const AccountPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildTopBar(),
            // Top Bar
            const SizedBox(height: 24),
            // MODIFIED: Switched back to RecentPurchaseCard
            // When no order exists, this card will show the Promo Banner design.
            const RecentPurchaseCard(),
            const SizedBox(height: 24),
            _buildSectionTitle("Categories", "See All", () {
              setState(() => _selectedIndex = 1);
            }),
            const SizedBox(height: 16),
            _buildCategoriesList(),
            const SizedBox(height: 24),
            _buildSectionTitle("Bestseller Products", "See All", () {}),
            const SizedBox(height: 16),
            // Shows Real Data from Supabase
            _buildRealBestsellersList(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  /// Builds the top bar containing the Scan button, Search bar, and Cart button.
  Widget _buildTopBar() {
    return Row(
      children: [
        // 👤 PROFILE ICON (replaced scanner)
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AccountPage(),
              ),
            );
          },
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline, //  Profile icon
              color: Colors.black87,
              size: 26,
            ),
          ),
        ),

        const SizedBox(width: 12),

        //  SEARCH BAR
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
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

        //  CART ICON WITH BADGE
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
            ),

            //  CART BADGE
            Consumer<CartData>(
              builder: (context, cartData, child) {
                if (cartData.items.isEmpty) return const SizedBox.shrink();
                return Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E88E5),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartData.items.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Reusable section title with "See All" button
  Widget _buildSectionTitle(String title,
      String actionText,
      VoidCallback onAction,) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionText,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5A9CA0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the horizontal list of circular categories
  Widget _buildCategoriesList() {
    return SizedBox(
      height: 110, // Increased from 100
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Placeholder for categories, you can map real data here later
          _buildCategoryItem(Icons.medication, "Medicines", Colors.blue[100]!),
          const SizedBox(width: 20),
          _buildCategoryItem(Icons.favorite, "Health", Colors.red[100]!),
          const SizedBox(width: 20),
          _buildCategoryItem(Icons.wb_sunny, "Vitamins", Colors.orange[100]!),
          const SizedBox(width: 20),
          _buildCategoryItem(Icons.spa, "Care", Colors.green[100]!),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(child: Icon(icon, color: Colors.black54, size: 28)),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Fetches Real Products from Supabase
  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductPage(product: product)),
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
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) =>
                      Container(
                        color: Colors.grey[100],
                        child: const Center(
                            child: Icon(Icons.image_not_supported)),
                      ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              product.category,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  "${product.rating.toStringAsFixed(1)}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  // Prevent price overflow
                  child: Text(
                    "₹${product.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                InkWell(
                  onTap: () {
                    final cartItem = CartItem(
                      id: product.id,
                      name: product.name,
                      title: product.name,
                      brand: product.category,
                      size: "Standard",
                      price: product.price,
                      imagePath: product.image,
                      imageUrl: product.image,
                    );
                    context.read<CartData>().addItem(cartItem);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Item added to cart ")),
                    );
                  },
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5A9CA0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Fetches Real Products from Supabase
  Widget _buildRealBestsellersList() {
    return SizedBox(
      height: 280, // Increased from 260 for safety
      child: FutureBuilder<List<Product>>(
        future: _productRepo.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No products available"));
          }

          final products = snapshot.data!;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(product);
            },
          );
        },
      ),
    );
  }

  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Product>> _fetchProducts() async {
    final res = await supabase
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return (res as List)
        .map((e) => Product.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Builds the horizontal list of product cards
  Widget _buildBestsellersList() {
    return FutureBuilder<List<Product>>(
      future: _fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 280, // Increased from 260
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: 280, // Increased from 260
            child: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const SizedBox(
            height: 280, // Increased from 260
            child: Center(child: Text("No products available")),
          );
        }

        return SizedBox(
          height: 280, // Increased from 260
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return GestureDetector(
                //  Product details page open (same as before)
                onTap: () =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductPage(product: product),
                      ),
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
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //  Image
                      Expanded(
                        child: Center(
                          child: Image.network(
                            product.image,
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) =>
                                Container(
                                  color: Colors.grey[100],
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      //  Title
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 4),

                      //  Category
                      Text(
                        product.category,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 8),

                      //  Rating Row (dynamic)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            "${product.rating.toStringAsFixed(1)}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      //  Price and Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            // Prevent price overflow in list Bestseller
                            child: Text(
                              "₹${product.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),

                          //  Add Button (+) -> cart add + open CartPage
                          InkWell(
                            onTap: () {
                              //  stop GestureDetector tap (details page)
                              // otherwise both tap trigger ho jayega
                              // so we do: onTapDown trick not needed, just use InkWell here

                              final cartItem = CartItem(
                                id: product.id,
                                //  UUID from Supabase
                                name: product.name,
                                title: product.name,
                                brand: product.category,
                                size: "Standard",
                                price: product.price,
                                imagePath: product.image,
                                imageUrl: product.image,
                              );

                              context.read<CartData>().addItem(cartItem);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CartPage(),
                                ),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Item added to cart "),
                                ),
                              );
                            },
                            child: Container(
                              height: 32,
                              width: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFF5A9CA0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
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
      },
    );
  }

  /// Custom Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    final navItems = [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.grid_view, 'label': 'Category'},

      //  Chatbot (Wishlist replaced)
      {'icon': Icons.chat_bubble_outline, 'label': 'Chatbot'},

      {'icon': Icons.receipt_long, 'label': 'Order'},

      //  AI (Profile replaced)
      {'icon': Icons.smart_toy, 'label': 'AI'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              return _buildNavItem(
                item['icon'] as IconData,
                item['label'] as String,
                index,
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 4) {
          //  AI Page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AiAssistantPage(),
            ),
          );
        } else if (index == 3) {
          //  Orders Page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OrdersPage()),
          );
        } else if (index == 2) {
          //  Chatbot Page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatDetailScreen(clientName: 'Abhishek',)),
          );
        } else {
          // Home / Category
          setState(() => _selectedIndex = index);
        }
      },
      child: Container(
        color: Colors.transparent,
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
                fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

  /// A stateful widget that fetches the most recent order.
/// If no order is found, it displays the PROMO BANNER (from screenshot).
class RecentPurchaseCard extends StatefulWidget {
  const RecentPurchaseCard({super.key});

  @override
  State<RecentPurchaseCard> createState() => _RecentPurchaseCardState();
}

class _RecentPurchaseCardState extends State<RecentPurchaseCard> {
  Map<String, dynamic>? recentOrder;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentOrder();
  }

  Future<void> _fetchRecentOrder() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await supabase
          .from('orders') // Ensure this matches your Supabase table name
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      setState(() {
        recentOrder = response;
        isLoading = false;
      });
    } catch (e) {
      // Handle errors (e.g., table doesn't exist yet)
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _loadingUI();
    }

    if (recentOrder == null) {
      return _noOrderUI(); // This now shows the Promo Banner design
    }

    return _orderUI();
  }

  // ---------------- UI STATES ----------------

  Widget _loadingUI() {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.grey[200],
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  /// Displays the Promo Banner when there are no recent purchases.
  /// Matches the visual style of the teammate's screenshot.
  Widget _noOrderUI() {
    return Container(
      width: double.infinity,
      height: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF5A9CA0), Color(0xFF3A6B6E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A9CA0).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "No Recent Purchase",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Displays the actual Recent Purchase details if an order exists.
  Widget _orderUI() {
    return Container(
      constraints: const BoxConstraints(minHeight: 170),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF5A9CA0), Color(0xFF3A6B6E)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Recent Purchase",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Order ID: ${recentOrder!['id']}",
            style: const TextStyle(color: Colors.white70),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "Items: ${recentOrder!['total_items'] ?? 0}",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Status: ${recentOrder!['status'] ?? 'Pending'}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
