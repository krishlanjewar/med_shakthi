import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupplierOrdersPage extends StatelessWidget {
  const SupplierOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrdersList(status: 'pending'),
            OrdersList(status: 'accepted'),
            OrdersList(status: 'rejected'),
          ],
        ),
      ),
    );
  }
}

/* ---------------- ORDERS LIST ---------------- */

class OrdersList extends StatelessWidget {
  final String status;
  const OrdersList({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final supplierId = supabase.auth.currentUser!.id;

    return FutureBuilder(
      future: supabase
          .from('orders')
          .select()
          .eq('supplier_id', supplierId)
          .eq('status', status)
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return Center(child: Text('No $status orders'));
        }

        final orders = snapshot.data as List;

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return OrderCard(order: orders[index]);
          },
        );
      },
    );
  }
}

/* ---------------- ORDER CARD ---------------- */

class OrderCard extends StatelessWidget {
  final Map order;
  const OrderCard({required this.order, super.key});

  @override
  Widget build(BuildContext context) {
    final items = order['order_items'] as List<dynamic>;

    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${order['id'].toString().substring(0, 6)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('Total: ₹${order['total_amount']}'),
            Text('Payment: ${order['payment_status']}'),
            const Divider(),

            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),

            ...items.map(
              (item) => Text('• ${item['product']} × ${item['qty']}'),
            ),

            const SizedBox(height: 10),

            if (order['status'] == 'pending')
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => acceptOrder(order['id']),
                    child: const Text('Accept'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () => rejectOrder(context, order['id']),
                    child: const Text('Reject'),
                  ),
                ],
              ),

            if (order['status'] == 'rejected' &&
                order['rejection_reason'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Reason: ${order['rejection_reason']}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- ACTIONS ---------------- */

Future<void> acceptOrder(String orderId) async {
  await Supabase.instance.client
      .from('orders')
      .update({'status': 'accepted'})
      .eq('id', orderId);
}

Future<void> rejectOrder(BuildContext context, String orderId) async {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Reject Order'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Reason for rejection'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await Supabase.instance.client
                .from('orders')
                .update({
                  'status': 'rejected',
                  'rejection_reason': controller.text,
                })
                .eq('id', orderId);

            if (!context.mounted) return;
            Navigator.pop(context);
          },
          child: const Text('Reject'),
        ),
      ],
    ),
  );
}
