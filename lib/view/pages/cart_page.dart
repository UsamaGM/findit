import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findit/view/pages/pages.dart';
import 'package:findit/view/components/components.dart';
import 'package:findit/controller/services/services.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<dynamic> cartItems = [];
  String? id;
  double total = 0.0;
  List<dynamic> selectedItems = [];

  @override
  void initState() {
    super.initState();
    id = context.read<Shared>().userId;
    fetchData();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final server = context.read<HttpService>();
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                "Total: Rs.${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (BuildContext context, int index) {
                var item = cartItems[index];
                return Dismissible(
                  key: Key(item["id"].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) async {
                    await server.delete(
                      route: "cart/single",
                      body: {
                        "buyerId": id,
                        "productId": cartItems[index]['id']
                      },
                    );
                    setState(() {
                      cartItems.removeAt(index);
                      updateTotal();
                    });
                  },
                  child: CartEntity(
                    item: item,
                    isSelected: selectedItems.contains(item),
                    update: updateTotal,
                    onChanged: (isSelected) {
                      setState(() {
                        if (isSelected) {
                          selectedItems.add(item);
                        } else {
                          selectedItems.remove(item);
                        }
                        updateTotal();
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (cartItems.isEmpty) {
            showErrorSnackBar(context, "Add items to cart to proceed");
          } else if (selectedItems.isEmpty) {
            showErrorSnackBar(context, "No items selected");
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckoutPage(
                  details: {
                    "totalPrice": total,
                    "productIds": selectedItems.map((e) => e['id']).toList(),
                    "quantities":
                        selectedItems.map((e) => e['quantity']).toList(),
                  },
                ),
              ),
            );
          }
        },
        label: Text(
          "Checkout",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 3,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> fetchData() async {
    try {
      final results = await context.read<HttpService>().get(
        route: "cart/fromId",
        queryParams: {"buyerId": id},
      );

      final products = jsonDecode(results.body)['products'];
      if (products != null) {
        setState(() {
          cartItems = products
              .map((value) => {
                    "id": value['id'],
                    "name": value['name'],
                    "price": value['price'],
                    "quantity": value['quantity'],
                    "image": value['image']
                  })
              .toList();
        });
      }
    } catch (error) {
      if (mounted) {
        showErrorDialog(context, "Error loading data");
      }
    }
  }

  void updateTotal() {
    setState(() {
      total = selectedItems.fold(0.0, (sum, item) {
        return sum + (item["price"] * item["quantity"]);
      });
    });
  }
}
