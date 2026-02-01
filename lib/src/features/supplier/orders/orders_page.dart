import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'orders_details_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final supabase = Supabase.instance.client;

  late RealtimeChannel ordersChannel;

  bool isLoading = true;
  String selectedStatus = "All";
  List<dynamic> orders = [];

  final List<String> statusList = [
    "All",
    "Pending",
    "Accepted",
    "Packed",
    "Dispatched",
    "Delivered",
    "Cancelled",
  ];

  @override
  void initState() {
    super.initState();
    fetchSupplierOrders();
    setupRealtime();
  }

  // 🔥 Fetch supplier-specific orders
  Future<void> fetchSupplierOrders() async {
    try {
      final supplierId = supabase.auth.currentUser!.id;

      final response = await supabase
          .from('orders')
          .select('''
            id,
            order_number,
            buyer_name,
            total_amount,
            status,
            created_at,
            order_items!inner (
              supplier_id,
              quantity
            )
          ''')
          .eq('order_items.supplier_id', supplierId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          orders = response;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ⚡ Supabase Realtime Listener
  void setupRealtime() {
    final supplierId = supabase.auth.currentUser!.id;

    ordersChannel = supabase.channel('supplier-orders-$supplierId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'order_items',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'supplier_id',
          value: supplierId,
        ),
        callback: (payload) {
          fetchSupplierOrders(); // 🔁 realtime refresh
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'orders',
        callback: (payload) {
          fetchSupplierOrders();
        },
      )
      ..subscribe();
  }

  @override
  void dispose() {
    supabase.removeChannel(ordersChannel);
    super.dispose();
  }

  List<dynamic> get filteredOrders {
    if (selectedStatus == "All") return orders;
    return orders.where((o) => o['status'] == selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          "Orders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // 🏷 Status Filter
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: statusList.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final status = statusList[index];
                final isSelected = selectedStatus == status;

                return GestureDetector(
                  onTap: () => setState(() => selectedStatus = status),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4CA6A8)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                ? const Center(child: Text("No orders found"))
                : ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) =>
                        _orderCard(context, filteredOrders[index]),
                  ),
          ),
        ],
      ),
    );
  }

  // 🧾 Order Card UI
  Widget _orderCard(BuildContext context, dynamic order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order #${order['order_number']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              _statusBadge(order['status']),
            ],
          ),
          const SizedBox(height: 6),
          Text(order['buyer_name']),
          const SizedBox(height: 4),
          Text("₹${order['total_amount']}"),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailsPage(orderId: order['id']),
                    ),
                  );
                },
                child: const Text(
                  "View Details",
                  style: TextStyle(
                    color: Color(0xFF4CA6A8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (order['status'] == "Pending")
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CA6A8),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text("Accept"),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case "Pending":
        color = Colors.orange;
        break;
      case "Delivered":
        color = Colors.green;
        break;
      case "Cancelled":
        color = Colors.red;
        break;
      default:
        color = const Color(0xFF4CA6A8);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
