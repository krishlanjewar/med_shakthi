import 'package:flutter/material.dart';
import 'package:med_shakthi/src/features/orders/return_product_page.dart';
// Ensure this import points to where you saved return_product_page.dart

class OrderPlacedScreen extends StatefulWidget {
  const OrderPlacedScreen({super.key});

  @override
  State<OrderPlacedScreen> createState() => _OrderPlacedScreenState();
}

class _OrderPlacedScreenState extends State<OrderPlacedScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _iconScale;
  late Animation<double> _screenScale;

  @override
  void initState() {
    super.initState();

    // Icon animation controller
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Screen scale animation controller
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Icon scale animation
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Screen scale animation
    _screenScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleAnimationController, curve: Curves.easeOut),
    );

    _iconAnimationController.forward();
    _scaleAnimationController.forward();
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ScaleTransition(
        scale: _screenScale,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Animated Success Checkmark
                      ScaleTransition(
                        scale: _iconScale,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4C8077,
                            ).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF4C8077),
                            size: 80,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Order Placed Successfully!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Your order #ORD-2026-001 has been processed and will be delivered shortly.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Order Summary Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order Summary",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const Divider(height: 30),
                            // Order Items with Return Logic
                            _buildOrderItem(
                              "Metformin 500mg",
                              "10 Strips • Sun Pharma",
                              "\$42.50",
                              // Pass dummy/real image URL here
                              "https://example.com/metformin.png",
                            ),
                            const SizedBox(height: 16),
                            _buildOrderItem(
                              "Dolo 650",
                              "5 Boxes • Micro Labs",
                              "\$12.00",
                              "https://example.com/dolo.png",
                            ),
                            const Divider(height: 30),
                            _buildPriceRow("Subtotal", "\$54.50"),
                            const SizedBox(height: 8),
                            _buildPriceRow("Tax (5%)", "\$2.72"),
                            const SizedBox(height: 8),
                            _buildPriceRow(
                              "Shipping",
                              "Free",
                              isDiscount: true,
                            ),
                            const Divider(height: 30),
                            _buildPriceRow(
                              "Total Paid",
                              "\$57.22",
                              isBold: true,
                              fontSize: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate back to Home
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C8077),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Continue Shopping",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // Navigate to Order Details/Track Order
                      },
                      child: const Text(
                        "Track Order",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(
    String title,
    String details,
    String priceString,
    String imageUrl,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Icon
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.medication, color: Color(0xFF4C8077)),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Price
              Text(
                priceString,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C8077),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // --- RETURN BUTTON ---
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                // Parse price string to double for the return page
                double priceValue =
                    double.tryParse(
                      priceString.replaceAll(RegExp(r'[^0-9.]'), ''),
                    ) ??
                    0.0;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReturnProductPage(
                      orderId: "ORD-2026-001", // Or mock ID
                      productId: "PROD-XYZ", // Or mock ID
                      productName: title,
                      productImage: imageUrl,
                      price: priceValue,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_return_outlined,
                      size: 14,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Return Item",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isDiscount
                ? Colors.green
                : (isBold ? Colors.black : Colors.black87),
          ),
        ),
      ],
    );
  }
}
