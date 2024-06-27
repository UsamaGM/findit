import 'dart:convert';

import 'package:findit/controller/services/services.dart';
import 'package:findit/view/components/components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SellerOrderPage extends StatefulWidget {
  const SellerOrderPage({super.key});

  @override
  State<SellerOrderPage> createState() => _SellerOrderPageState();
}

class _SellerOrderPageState extends State<SellerOrderPage> {
  List<dynamic> orders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData(context);
  }

  Future<void> _fetchData(BuildContext context) async {
    try {
      final id = context.read<Shared>().userId;
      final results = await context.read<HttpService>().get(
        route: "order/forSeller",
        queryParams: {"id": id},
      );
      setState(() {
        orders = jsonDecode(results.body);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load orders. Please try again later.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(child: CustomSpinKit())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      _errorMessage,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  )
                : orders.isEmpty
                    ? const Center(child: Text("No Orders yet!"))
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _buildOrderCard(orders[index]);
                        },
                      ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Buyer: ${order['buyerName'] ?? 'N/A'}\nProduct: ${order['productName'] ?? 'N/A'}\nQuantity: ${order['quantity'] ?? 'N/A'}\nTotal Amount: ${(order['quantity'] ?? 0) * (order['price'] ?? 0)}",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
