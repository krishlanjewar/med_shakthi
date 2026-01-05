import 'package:flutter/material.dart';
import 'package:med_shakthi/src/features/payment/payment.dart';

// --- DATA MODEL ---
class CartItem {
  final String id;
  final String title;
  final String brand;
  final String size;
  final double price;
  final String imagePath;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.brand,
    required this.size,
    required this.price,
    required this.imagePath,
    this.quantity = 1,
  });
}

// --- CART PAGE WIDGET ---
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Theme color (Teal/Green)
  final Color themeColor = const Color(0xFF4C8077);
  // Background color
  final Color backgroundColor = const Color(0xFFF5F7F9);

  // Dummy Data matched to your image
  final List<CartItem> _cartItems = [
    CartItem(
      id: '1',
      title: 'Dietary Antioxidant Protection',
      brand: 'SAN Pharma',
      size: 'Size: 120 count',
      price: 18.99,
      imagePath: 'assets/images/cart_image_1.jpg',
      quantity: 1,
    ),
    CartItem(
      id: '2',
      title: 'Stress Management L-Theanine',
      brand: '21st Century Store',
      size: 'Size: 65 count',
      price: 21.99,
      imagePath: 'assets/images/cart_image_2.jpg',
      quantity: 1,
    ),
    CartItem(
      id: '3',
      title: 'Non-Drowsy Cold & Flu Relief',
      brand: 'Puregen Labs',
      size: 'Size: 50 count',
      price: 24.99,
      imagePath: 'assets/images/cart_image_3.jpg',
      quantity: 1,
    ),
  ];

  // Calculations
  double get subTotal =>
      _cartItems.fold(0, (total, item) => total + (item.price * item.quantity));

// Hardcoded shipping
  int get shipping => 10; // Now an integer

  // Total remains a double because subTotal is a double
  double get total => subTotal + shipping;

  void _incrementQuantity(int index) {
    setState(() {
      _cartItems[index].quantity++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                children: [
                  _buildIconButton(Icons.arrow_back, onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  }),
                  const SizedBox(width: 16),
                  const Text(
                    "Cart",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  _buildIconButton(Icons.delete_outline, onTap: () {}),
                  const SizedBox(width: 8),
                  _buildIconButton(Icons.share_outlined, onTap: () {}),
                ],
              ),
            ),

            // --- CART LIST ---
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _cartItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  return _buildCartItemCard(_cartItems[index], index);
                },
              ),
            ),

            // --- BOTTOM SUMMARY SECTION ---
            Container(
              padding: const EdgeInsets.all(24),
              // REMOVED BoxDecoration: Now it is transparent and matches background
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSummaryRow("Sub Total", subTotal),
                  const SizedBox(height: 12),
                  _buildSummaryRow("Shipping & Tax", shipping),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "\$${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (_cartItems.isEmpty) return;
                        _showCheckoutConfirmDialog();
                      },
                      child: const Text(
                        "Checkout",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildIconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 3,
            )
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }

  Widget _buildSummaryRow(String label, num value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
          ),
        ),
        Text(
          "\$${value is int ? value.toString() : value.toStringAsFixed(2)}",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem item, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Image
          Container(
            width: 80,
            height: 100,
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (c, o, s) =>
                    const Icon(Icons.medication, size: 40, color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  item.brand,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 8),

                // Size and Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.size,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      "\$${item.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Qty and Trash Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildQuantityBtn(
                            Icons.remove, () => _decrementQuantity(index)),
                        SizedBox(
                          width: 30,
                          child: Center(
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),
                        ),
                        _buildQuantityBtn(
                            Icons.add, () => _incrementQuantity(index)),
                      ],
                    ),

                    // Trash Icon
                    GestureDetector(
                      onTap: () => _removeItem(index),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Icon(Icons.delete_outline,
                            size: 18, color: Colors.grey[400]),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuantityBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 16, color: Colors.grey[600]),
      ),
    );
  }

  void _showCheckoutConfirmDialog() {
    final int totalItems =
        _cartItems.fold(0, (sum, item) => sum + item.quantity);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirm Checkout',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are placing an order for $totalItems item(s).',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              _dialogPriceRow('Subtotal', subTotal),
              _dialogPriceRow('Shipping & Tax', shipping),
              const Divider(height: 24),
              _dialogPriceRow(
                'Total Payable',
                total,
                isBold: true,
              ),
              const SizedBox(height: 12),
              const Text(
                'Please confirm to proceed with payment.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PaymentMethodScreen()));
                // _handleCheckout();
              },
              child: const Text('Confirm Order'),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogPriceRow(
    String label,
    num value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            '\$${value is int ? value : value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
