import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Imports from your snippet (Provider & Data)
// Corrected paths based on your previous file structure
import '../../../checkout/presentation/screens/AddressSelectScreen.dart';
import '../../data/cart_data.dart';
import '../../data/cart_item.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  final Color themeColor = const Color(0xFF4C8077);
  final Color backgroundColor = const Color(0xFFF5F7F9);

  // Hardcoded shipping cost
  final int shipping = 10;

  @override
  Widget build(BuildContext context) {
    // Listen to changes in CartData using Provider.of
    final cart = Provider.of<CartData>(context);

    // Shipping logic: 199 if items exist, 0 otherwise
    final int shipping = cart.items.isNotEmpty ? 10 : 0;

    // Calculate total for display
    final double total = cart.subTotal + shipping;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Row(
                children: [
                  _buildIconButton(
                    context,
                    Icons.arrow_back,
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Cart",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  _buildIconButton(
                    context,
                    Icons.delete_outline,
                    onTap: () {
                      cart.clearCart();
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(context, Icons.share_outlined, onTap: () {}),
                ],
              ),
            ),

            // --- CART LIST ---
            Expanded(
              child: cart.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your cart is empty',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: cart.items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        return _buildCartItemCard(
                          context,
                          cart,
                          cart.items[index],
                          index,
                        );
                      },
                    ),
            ),

            // --- BOTTOM SUMMARY SECTION ---
            // Only show if cart is NOT empty
            if (cart.items.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSummaryRow("Sub Total", cart.subTotal),
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
                          "₹${total.toStringAsFixed(2)}",
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
                          if (cart.items.isEmpty) return;
                          _showCheckoutConfirmDialog(context, cart, shipping);
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
              ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildIconButton(
    BuildContext context,
    IconData icon, {
    VoidCallback? onTap,
  }) {
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
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
            ),
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
        Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
        Text(
          "₹${value is int ? value.toString() : value.toStringAsFixed(2)}",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemCard(
    BuildContext context,
    CartData cart,
    CartItem item,
    int index,
  ) {
    // Check if the image path is a URL (http/https) or a local asset
    final bool isNetworkImage = item.imagePath?.startsWith('http') ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              child: isNetworkImage
                  ? Image.network(
                      item.imagePath!,
                      fit: BoxFit.contain,
                      errorBuilder: (c, o, s) => const Icon(
                        Icons.medication,
                        size: 40,
                        color: Colors.grey,
                      ),
                    )
                  : Image.asset(
                      item.imagePath ?? '',
                      fit: BoxFit.contain,
                      errorBuilder: (c, o, s) => const Icon(
                        Icons.medication,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 10),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Use fallback if title is null
                Text(
                  item.title ?? item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                // Use fallback if brand is null
                Text(
                  item.brand ?? '',
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
                    // Use fallback if size is null
                    Text(
                      item.size ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    Text(
                      "₹${item.price.toStringAsFixed(2)}",
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
                          Icons.remove,
                          () => cart.decrement(index),
                        ),
                        SizedBox(
                          width: 30,
                          child: Center(
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        _buildQuantityBtn(
                          Icons.add,
                          () => cart.increment(index),
                        ),
                      ],
                    ),

                    // Trash Icon
                    GestureDetector(
                      onTap: () => cart.remove(index),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

  void _showCheckoutConfirmDialog(
    BuildContext context,
    CartData cart,
    int shipping,
  ) {
    // Added shipping arg
    // Explicitly casting quantity to int to avoid type errors
    final int totalItems = cart.items.fold(
      0,
      (sum, item) => sum + item.quantity.toInt(),
    );

    // Calculate final total based on live data
    final double total = cart.subTotal + shipping;

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
              _dialogPriceRow('Subtotal', cart.subTotal),
              _dialogPriceRow('Shipping & Tax', shipping),
              const Divider(height: 24),
              _dialogPriceRow('Total Payable', total, isBold: true),
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
                Navigator.pop(context); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressSelectScreen(),
                  ),
                );
              },
              child: const Text('Confirm Order'),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogPriceRow(String label, num value, {bool isBold = false}) {
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
            '₹${value is int ? value : value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
