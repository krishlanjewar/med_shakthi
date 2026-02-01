import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupplierCategoryPage extends StatefulWidget {
  const SupplierCategoryPage({super.key});

  @override
  State<SupplierCategoryPage> createState() => _SupplierCategoryPageState();
}

class _SupplierCategoryPageState extends State<SupplierCategoryPage> {
  final Color themeColor = const Color(0xFF6AA39B);
  final SupabaseClient supabase = Supabase.instance.client;

  int selectedCategoryIndex = 0;
  bool sidebarVisible = true;

  String? selectedSubCategory;
  bool loadingProducts = false;

  List<Map<String, dynamic>> products = [];

  final List<Map<String, dynamic>> categories = [
    {
      "name": "Medicines",
      "icon": Icons.medication_outlined,
      "items": ["Tablets", "Syrups", "Capsules", "Injections", "Pain Relief"],
    },
    {
      "name": "Supplements",
      "icon": Icons.local_pharmacy_outlined,
      "items": ["Protein", "Vitamins", "Omega 3", "Weight Gain", "Immunity"],
    },
    {
      "name": "Personal Care",
      "icon": Icons.spa_outlined,
      "items": ["Skin Care", "Hair Care", "Body Care", "Cosmetics"],
    },
    {
      "name": "Baby Care",
      "icon": Icons.child_friendly_outlined,
      "items": ["Diapers", "Baby Food", "Baby Lotion", "Baby Soap"],
    },
    {
      "name": "Devices",
      "icon": Icons.monitor_heart_outlined,
      "items": ["BP Monitor", "Thermometer", "Glucometer", "Nebulizer"],
    },
  ];

  Future<void> fetchProducts({
    required String category,
    required String subCategory,
  }) async {
    setState(() {
      loadingProducts = true;
      products.clear();
    });

    final response = await supabase
        .from('products')
        .select()
        .eq('category', category)
        .eq('sub_category', subCategory);

    setState(() {
      products = List<Map<String, dynamic>>.from(response);
      loadingProducts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = categories[selectedCategoryIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Categories", style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search categories...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 500) {
                  setState(() => sidebarVisible = true);
                } else if (details.primaryVelocity! < -500) {
                  setState(() => sidebarVisible = false);
                }
              },
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: sidebarVisible ? 110.0 : 0.0,
                    color: Colors.white,
                    child: sidebarVisible
                        ? ListView.builder(
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              final isSelected = index == selectedCategoryIndex;

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedCategoryIndex = index;
                                    selectedSubCategory = null;
                                    products.clear();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? themeColor.withValues(alpha: 0.12)
                                        : Colors.white,
                                    border: Border(
                                      left: BorderSide(
                                        color: isSelected
                                            ? themeColor
                                            : Colors.transparent,
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        cat["icon"],
                                        color: isSelected
                                            ? themeColor
                                            : Colors.grey,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        cat["name"],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedSubCategory == null
                                ? selectedCategory["name"]
                                : "${selectedCategory["name"]} → $selectedSubCategory",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: loadingProducts
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : GridView.builder(
                                    itemCount: selectedSubCategory == null
                                        ? (selectedCategory["items"] as List)
                                              .length
                                        : products.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 14,
                                          crossAxisSpacing: 14,
                                          childAspectRatio: 1.2,
                                        ),
                                    itemBuilder: (context, i) {
                                      if (selectedSubCategory == null) {
                                        final itemName =
                                            (selectedCategory["items"]
                                                as List)[i];
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedSubCategory = itemName;
                                            });
                                            fetchProducts(
                                              category:
                                                  selectedCategory["name"],
                                              subCategory: itemName,
                                            );
                                          },
                                          child: _buildTile(
                                            title: itemName,
                                            icon: Icons.category_outlined,
                                          ),
                                        );
                                      } else {
                                        final product = products[i];
                                        return _buildTile(
                                          title: product['name'],
                                          subtitle:
                                              "₹${product['price'] ?? '--'}",
                                          icon: Icons.medication,
                                        );
                                      }
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required String title,
    String? subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: themeColor),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
          ],
        ],
      ),
    );
  }
}
