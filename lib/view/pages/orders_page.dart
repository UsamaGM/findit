import 'dart:convert';

import 'package:findit/controller/services/services.dart';
import 'package:findit/view/components/components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> orders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: _fetchData(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CustomSpinKit());
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (orders.isEmpty) {
                return const Center(child: Text("No Orders yet!"));
              }
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildOrderCard(orders[index]);
                },
              );
            } else {
              return const Center(child: Text("Error fetching orders"));
            }
          },
        ),
      ),
    );
  }

  Future<void> _fetchData(BuildContext context) async {
    try {
      final id = context.read<Shared>().userId;
      final results = await context
          .read<HttpService>()
          .get(route: "order/fromId", queryParams: {"id": id});

      orders = jsonDecode(results.body)['filtered'];
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget _buildOrderCard(dynamic order) {
    return InkWell(
      onTap: () => _showOrderDetailsDialog(order),
      child: Card(
        elevation: 4.0,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'OrderID: ${order['orderId']}',
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Total Price: Rs.${order['totalPrice']}',
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetailsDialog(dynamic order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(
                minHeight: 100,
                maxHeight: 300,
              ),
              child: ListView.builder(
                itemCount: order['sellerNames'].length,
                itemBuilder: (context, index) {
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tileColor: Theme.of(context).colorScheme.secondary,
                    textColor: Theme.of(context).colorScheme.onSecondary,
                    title: Text("Seller: ${order['sellerNames'][index]}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Product: ${order['productNames'][index]}"),
                        Text("Quantity: ${order['quantity'][index]}"),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
