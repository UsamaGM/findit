import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:findit/controller/services/services.dart';
import 'package:findit/view/components/components.dart';

class InventoryManagementPage extends StatefulWidget {
  const InventoryManagementPage({super.key});

  @override
  createState() => _InventoryManagementPageState();
}

class _InventoryManagementPageState extends State<InventoryManagementPage> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final result = await context
          .read<HttpService>()
          .get(route: "product/forSeller", queryParams: {
        "id": context.read<Shared>().userId,
      });

      setState(() {
        products = jsonDecode(result.body);
      });
    } catch (e) {
      _showErrorDialog("Failed to load products");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildProductCard(products[index], theme);
                },
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, ThemeData theme) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product['productName'],
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Stock: ${product['stock']}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Price: Rs.${product['price'].toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _editProduct(context, product, theme);
                  },
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                TextButton(
                  onPressed: () {
                    _deleteProduct(context, product, theme);
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editProduct(
      BuildContext context, Map<String, dynamic> product, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    labelStyle: TextStyle(color: theme.primaryColor),
                  ),
                  controller:
                      TextEditingController(text: product["productName"]),
                  onChanged: (value) {
                    product['productName'] = value;
                  },
                ),
                const SizedBox(height: 8.0),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Stock',
                    labelStyle: TextStyle(color: theme.primaryColor),
                  ),
                  keyboardType: TextInputType.number,
                  controller:
                      TextEditingController(text: product['stock'].toString()),
                  onChanged: (value) {
                    product['stock'] = int.tryParse(value) ?? 0;
                  },
                ),
                const SizedBox(height: 8.0),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(
                      color: theme.primaryColor,
                    ),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller:
                      TextEditingController(text: product['price'].toString()),
                  onChanged: (value) {
                    product['price'] = double.tryParse(value) ?? 0.0;
                  },
                ),
                const SizedBox(height: 16.0),
                CustomButton(
                  title: "Save",
                  onTap: () async {
                    try {
                      await context
                          .read<HttpService>()
                          .post(route: "product/update", body: {
                        "productId": product['productId'],
                        "sellerId": context.read<Shared>().userId,
                        "name": product['productName'],
                        "typeId": product['typeId'],
                        "price": product['price'],
                        "stock": product['stock'],
                        "description": product['description'],
                      });
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      _showSuccessDialog("Product updated successfully");
                      setState(() {});
                    } catch (e) {
                      _showErrorDialog("Failed to update product");
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteProduct(
      BuildContext context, Map<String, dynamic> product, ThemeData theme) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text(
              'Are you sure you want to delete ${product["productName"]}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await context.read<HttpService>().delete(
                    route: "product/delete",
                    body: {'id': product['productId']},
                  );
                  setState(() {
                    products.removeWhere(
                      (element) => element['productId'] == product['productId'],
                    );
                  });
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  _showSuccessDialog("Product deleted successfully");
                } catch (e) {
                  _showErrorDialog("Failed to delete product");
                }
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
