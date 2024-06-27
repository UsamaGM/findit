import 'dart:convert';

import 'package:findit/controller/services/services.dart';
import 'package:findit/view/components/components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key, required this.id});

  final int id;

  Future<Map<String, dynamic>?> fetchData(BuildContext context) async {
    try {
      final results = await context.read<HttpService>().get(
        route: "product/fromId",
        queryParams: {"productId": id.toString()},
      );
      return jsonDecode(results.body)['product'];
    } catch (error) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchData(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final product = snapshot.data!;
            return Scaffold(
              appBar: buildAppBar(theme, context),
              bottomNavigationBar: NavBar(
                productName: product['productName'],
                id: id,
                stock: product['stock'],
              ),
              body: buildBody(product, context),
            );
          } else {
            return Scaffold(
              appBar: buildAppBar(theme, context),
              body: Center(
                child: Text(
                  "Connection failure",
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }
        } else {
          return Scaffold(
            appBar: buildAppBar(theme, context),
            body: const CustomSpinKit(),
          );
        }
      },
    );
  }

  AppBar buildAppBar(ThemeData theme, BuildContext context) {
    return AppBar(
      backgroundColor: theme.colorScheme.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Product Details',
        style: TextStyle(
          color: theme.colorScheme.onBackground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.red),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget buildBody(Map<String, dynamic> product, BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final images = List<String>.from(product['images']);
    final description = product['description'];
    final stock = product['stock'];
    final price = product['price'];
    final productName = product['productName'];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 250,
            child: ImageSlider(imageUrls: images),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs. $price',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$stock remaining',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildExpansionTile('Description', description, theme),
                const SizedBox(height: 15),
                _buildExpansionTile(
                  'Delivery & Return',
                  "Easy return within one week of use.",
                  theme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            child: buildReviewsCard(theme),
          )
        ],
      ),
    );
  }

  InkWell buildReviewsCard(ThemeData theme) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {},
      child: Card(
        elevation: 0,
        color: theme.colorScheme.primaryContainer,
        surfaceTintColor: theme.colorScheme.secondary,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "See reviews",
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.colorScheme.onPrimaryContainer,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionTile(String title, String content, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.primary,
      surfaceTintColor: theme.colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              content,
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NavBar extends StatefulWidget {
  const NavBar({
    super.key,
    required this.productName,
    required this.id,
    required this.stock,
  });

  final String productName;
  final int id;
  final int stock;

  @override
  createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int quantity = 1;

  void onAdd() {
    if (quantity < widget.stock) {
      setState(() {
        quantity++;
      });
    }
  }

  void onSub() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  Future<void> _addToCart() async {
    if (quantity > 0) {
      try {
        await context.read<HttpService>().post(
          route: "cart/add",
          body: {
            "buyerId": context.read<Shared>().userId,
            "productId": widget.id,
            "quantity": quantity
          },
        ).then((value) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(
                "$quantity ${widget.productName} item${quantity > 1 ? "s" : ""} added to cart",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("Go to Cart"),
                ),
              ],
            ),
          );
        });
      } catch (error) {
        debugPrint(error.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: onSub,
                color: Theme.of(context).colorScheme.onSecondary,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 25),
              SizedBox(
                width: 20,
                child: Text(
                  quantity.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 25),
              IconButton(
                onPressed: onAdd,
                color: Theme.of(context).colorScheme.onSecondary,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _addToCart,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Add To Cart'),
          ),
        ],
      ),
    );
  }
}
